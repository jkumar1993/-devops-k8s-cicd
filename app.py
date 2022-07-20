from flask import Flask, render_template
import random

app = Flask(__name__)

# list of cat images
image_urls_map = {
    "https://versha-project.s3-us-west-2.amazonaws.com/compressed_jenkins-min.jpg": "https://versha-project.s3-us-west-2.amazonaws.com/IMG_9086.JPG",
    "https://versha-project.s3-us-west-2.amazonaws.com/compressed_jenkins-min.jpg": "https://versha-project.s3-us-west-2.amazonaws.com/IMG_9086.JPG",
}


@app.route("/")
def index():
    key = random.choice(list(image_urls_map))
    return render_template("index.html", smallcase_url=image_urls_map, image_url=key)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
    
