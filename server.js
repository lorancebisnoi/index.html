const express = require("express");
const https = require("https");
const http = require("http");
const { URL } = require("url");

const app = express();

app.use(express.json());
app.use(express.static("public"));

app.post("/download", async (req, res) => {
    try {
        const videoUrl = req.body.url;

        if (!videoUrl) {
            return res.status(400).json({
                error: "Video URL डालें"
            });
        }

        const parsed = new URL(videoUrl);

        if (!["http:", "https:"].includes(parsed.protocol)) {
            return res.status(400).json({
                error: "Invalid URL"
            });
        }

        const client =
            parsed.protocol === "https:" ? https : http;

        client.get(videoUrl, response => {

            if (response.statusCode !== 200) {
                return res.status(400).json({
                    error: "Video उपलब्ध नहीं है"
                });
            }

            const contentType =
                response.headers["content-type"] || "";

            if (!contentType.startsWith("video/")) {
                return res.status(400).json({
                    error:
                    "यह direct video file नहीं है"
                });
            }

            res.setHeader(
                "Content-Type",
                contentType
            );

            res.setHeader(
                "Content-Disposition",
                'attachment; filename="video.mp4"'
            );

            response.pipe(res);

        }).on("error", () => {

            res.status(500).json({
                error: "Download failed"
            });

        });

    } catch (error) {

        res.status(400).json({
            error: "Invalid URL"
        });

    }
});

app.listen(3000, () => {
    console.log(
        "Server running: http://localhost:3000"
    );
});
