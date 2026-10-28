import os
from functools import wraps

import oracledb
from flask import Flask, flash, redirect, render_template, request, session, url_for

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "change-me")

DB = dict(
    user=os.getenv("DB_USER", "SYSTEM"),
    password=os.getenv("DB_PASSWORD", "Nishant@11"),
    dsn=os.getenv("DB_DSN", "localhost:1522/FREEPDB1"),
)


# ---------- DB helpers ----------
def conn():
    return oracledb.connect(**DB)


def proc(name, args):
    with conn() as c:
        c.cursor().callproc(name, args)


def func(name, rtype, args):
    with conn() as c:
        return c.cursor().callfunc(name, rtype, args)


def rows(name, args=()):
    """Call a package function that returns a SYS_REFCURSOR."""
    with conn() as c:
        cur = c.cursor()
        rc = cur.callfunc(name, oracledb.DB_TYPE_CURSOR, list(args))
        return rc.fetchall()


def query(sql, params=()):
    with conn() as c:
        cur = c.cursor()
        cur.execute(sql, params)
        return cur.fetchall()


def safe(action, ok_msg=None):
    """Run action(); flash Oracle errors nicely. Returns True on success."""
    try:
        action()
        if ok_msg:
            flash(ok_msg, "ok")
        return True
    except oracledb.DatabaseError as e:
        msg = str(e.args[0].message).split("\n")[0]
        flash(msg.replace("ORA-2000", "Error: ORA-2000"), "err")
        return False


# ---------- auth ----------
def login_required(admin=False):
    def deco(f):
        @wraps(f)
        def wrapper(*a, **kw):
            if "user_id" not in session:
                return redirect(url_for("login"))
            if admin and session.get("role") != "ADMIN":
                flash("Admin only", "err")
                return redirect(url_for("index"))
            return f(*a, **kw)
        return wrapper
    return deco


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        f = request.form
        if safe(lambda: proc("bookstore_pkg.register_user",
                             [f["name"], f["email"], f["password"], f["address"]]),
                "Registered! Please log in."):
            return redirect(url_for("login"))
    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        uid = func("bookstore_pkg.login", int, [request.form["email"], request.form["password"]])
        if uid:
            role = query("SELECT role FROM users WHERE user_id = :1", [uid])[0][0]
            session.update(user_id=int(uid), role=role)
            return redirect(url_for("index"))
        flash("Invalid email or password", "err")
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/profile", methods=["GET", "POST"])
@login_required()
def profile():
    if request.method == "POST":
        safe(lambda: proc("bookstore_pkg.update_profile",
                          [session["user_id"], request.form["name"], request.form["address"]]),
             "Profile updated")
    u = query("SELECT name, email, address FROM users WHERE user_id = :1", [session["user_id"]])[0]
    return render_template("profile.html", u=u)


# ---------- books + cart ----------
@app.route("/")
@login_required()
def index():
    q = request.args.get("q", "")
    books = rows("bookstore_pkg.search_books", [q])
    return render_template("index.html", books=books, q=q)


@app.route("/cart")
@login_required()
def cart():
    items = query("""SELECT b.book_id, b.title, b.price, c.quantity, b.price * c.quantity
                       FROM cart_items c JOIN books b ON b.book_id = c.book_id
                      WHERE c.user_id = :1""", [session["user_id"]])
    total = sum(i[4] for i in items)
    return render_template("cart.html", items=items, total=total)


@app.route("/cart/add", methods=["POST"])
@login_required()
def cart_add():
    safe(lambda: proc("bookstore_pkg.add_to_cart",
                      [session["user_id"], int(request.form["book_id"]), int(request.form["qty"])]),
         "Cart updated")
    return redirect(request.referrer or url_for("cart"))


@app.route("/cart/remove", methods=["POST"])
@login_required()
def cart_remove():
    safe(lambda: proc("bookstore_pkg.remove_from_cart",
                      [session["user_id"], int(request.form["book_id"])]))
    return redirect(url_for("cart"))


@app.route("/checkout", methods=["POST"])
@login_required()
def checkout():
    out = {}
    if safe(lambda: out.update(id=func("bookstore_pkg.checkout", int, [session["user_id"]]))):
        flash(f"Order #{int(out['id'])} placed!", "ok")
        return redirect(url_for("orders"))
    return redirect(url_for("cart"))


@app.route("/orders")
@login_required()
def orders():
    return render_template("orders.html", rows=rows("bookstore_pkg.order_history", [session["user_id"]]))


# ---------- admin ----------
@app.route("/admin", methods=["GET", "POST"])
@login_required(admin=True)
def admin():
    if request.method == "POST":
        f = request.form
        act = f["action"]
        if act == "add":
            safe(lambda: proc("bookstore_pkg.add_book",
                              [f["title"], f["author"], f["category"], float(f["price"]), int(f["qty"])]),
                 "Book added")
        elif act == "update":
            safe(lambda: proc("bookstore_pkg.update_book",
                              [int(f["book_id"]), float(f["price"]), int(f["qty"])]), "Book updated")
        elif act == "remove":
            safe(lambda: proc("bookstore_pkg.remove_book", [int(f["book_id"])]), "Book removed")
        elif act == "status":
            safe(lambda: proc("bookstore_pkg.update_order_status",
                              [int(f["order_id"]), f["status"]]), "Status updated")
        return redirect(url_for("admin"))
    books = rows("bookstore_pkg.search_books", [""])
    all_orders = query("SELECT order_id, user_id, order_date, total_amount, status FROM orders ORDER BY order_id DESC")
    return render_template("admin.html", books=books, orders=all_orders)


@app.route("/reports")
@login_required(admin=True)
def reports():
    return render_template("reports.html",
                           best=rows("bookstore_pkg.best_sellers", [10]),
                           daily=rows("bookstore_pkg.sales_by_day"))


if __name__ == "__main__":
    app.run(debug=True)
