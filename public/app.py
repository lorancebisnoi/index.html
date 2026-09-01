from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import yt_dlp
import os
import uuid

app = Flask(__name__)
CORS(app)

DOWNLOAD_DIR = "downloads"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

@app.route("/download", methods=["POST"])
def download():
    data = request.get_json()
    url = data.get("url")

    if not url:
        return jsonify({"error": "URL required"}), 400

    filename = str(uuid.uuid4())
    output = os.path.join(DOWNLOAD_DIR, filename)

    options = {
        "format": "best[ext=mp4]/best",
        "outtmpl": output + ".%(ext)s",
        "noplaylist": True,
        "quiet": True
    }

    try:
        with yt_dlp.YoutubeDL(options) as ydl:
            info = ydl.extract_info(url, download=True)
            filepath = ydl.prepare_filename(info)

        return send_file(
            filepath,
            as_attachment=True,
            download_name="youtube-video.mp4"
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/")
def home():
    return "YouTube Downloader Backend Running"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
