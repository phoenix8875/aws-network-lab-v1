from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)

def get_db_data():
    conn = mysql.connector.connect(
        host="10.0.3.213",
        user="appuser",
        password="Password123",
        database="myproject"
    )
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM users;")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return [row[0] for row in rows]

@app.route('/api/data')
def get_data():
    try:
        data = get_db_data()
        return jsonify({"status": "success", "users": data})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
