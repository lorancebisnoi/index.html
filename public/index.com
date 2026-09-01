<!DOCTYPE html>
<html lang="hi">
<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Video Downloader</title>

<style>
body{
    margin:0;
    font-family:Arial;
    background:#111827;
    color:white;
    display:flex;
    justify-content:center;
    align-items:center;
    min-height:100vh;
}

.box{
    width:90%;
    max-width:500px;
    background:white;
    color:#111;
    padding:25px;
    border-radius:20px;
}

h1{
    text-align:center;
}

input{
    width:100%;
    padding:15px;
    box-sizing:border-box;
    border:1px solid #ddd;
    border-radius:10px;
    margin-top:15px;
}

button{
    width:100%;
    padding:15px;
    margin-top:15px;
    border:0;
    border-radius:10px;
    background:#111827;
    color:white;
    font-size:17px;
}

#status{
    margin-top:15px;
    text-align:center;
}
</style>
</head>

<body>

<div class="box">

<h1>🎬 Video Downloader</h1>

<input
 id="url"
 type="url"
 placeholder="Direct video URL डालें"
>

<button onclick="downloadVideo()">
⬇️ Download
</button>

<div id="status"></div>

</div>

<script>

async function downloadVideo(){

    const url =
        document.getElementById("url").value.trim();

    const status =
        document.getElementById("status");

    if(!url){

        status.innerText =
        "❌ URL डालें";

        return;
    }

    status.innerText =
    "⏳ Download शुरू हो रहा है...";

    try{

        const response = await fetch(
            "/download",
            {
                method:"POST",
                headers:{
                    "Content-Type":
                    "application/json"
                },
                body:JSON.stringify({
                    url:url
                })
            }
        );

        if(!response.ok){

            const data =
                await response.json();

            throw new Error(
                data.error || "Download failed"
            );
        }

        const blob =
            await response.blob();

        const link =
            document.createElement("a");

        link.href =
            URL.createObjectURL(blob);

        link.download =
            "video.mp4";

        link.click();

        URL.revokeObjectURL(
            link.href
        );

        status.innerText =
        "✅ Download complete";

    }catch(error){

        status.innerText =
        "❌ " + error.message;

    }

}

</script>

</body>
</html>
