import * as sketch from "./sketch.js"

const net = await posenet.load();
var currentPose = null;

/**
 * CAMERA STUFF
 */
// Code adapted from https://stackoverflow.com/questions/32104975/html5-mirroring-webcam-canvas
// Grab elements, create settings, etc.
var canvas = document.getElementById("webcamCanvas");
var context = canvas.getContext("2d");
// we don't need to append the video to the document
var video = document.createElement("video");
var videoObj = navigator.getUserMedia || navigator.mozGetUserMedia ? { 
    video: {
        width: { min: 1280,  max: 1280 },
        height: { min: 720,  max: 720 },
        require: ['width', 'height']
        }
    } :
    {
    video: {
        mandatory: {
            minWidth: 1280,
            minHeight: 720,
            maxWidth: 1280,
            maxHeight: 720
        }
    }
};

// Error message callback
function errBack (error) {
    console.log("Video capture error: ", error.code); 
};

// create a crop object that will be calculated on load of the video
var crop;
// create a variable that will enable us to stop the loop.
var raf;

navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
// Put video listeners into place
navigator.getUserMedia(videoObj, function(stream) {
    video.srcObject = stream;
    video.onplaying = function(){
        var croppedWidth = ( Math.min(video.videoHeight, canvas.height) / Math.max(video.videoHeight,canvas.height)) * Math.min(video.videoWidth, canvas.width),
        croppedX = ( video.videoWidth - croppedWidth) / 2;
        crop = {w:croppedWidth, h:video.videoHeight, x:croppedX, y:0};
        // call our loop only when the video is playing
        raf = requestAnimationFrame(loop);
    };
    video.onpause = function(){
        // stop the loop
        cancelAnimationFrame(raf);
    }
    video.play();
}, errBack);

// Variable that holds the latest pose prediction
var pose = null;

/**
 * Animation frame callback for drawing the webcam feed + wireframe onto the canvas
 */
function loop(){
    context.drawImage(video, crop.x, crop.y, crop.w, crop.h, 0, 0, canvas.width, canvas.height);
    drawWireFrame(pose);
    raf = requestAnimationFrame(loop);
}

/**
 * Takes a pose prediction from PoseNet and calls functions in ./sketch.js to draw the wireframe onto the canvas
 * @param {*} pose 
 */
function drawWireFrame(pose) {
    if (pose !== null) {
        sketch.drawKeypoints(pose.keypoints, 0, context);
        sketch.drawSkeleton(pose.keypoints, 0, context);
    }
}

var socket = io.connect('http://localhost:3000');

async function estimatePose(e) {
    pose = await net.estimateSinglePose(canvas, {
        flipHorizontal: false
    });
    currentPose = pose;
    // console.log(pose);
    let poseArr = unpackPose(pose);
    // Send this to local server
    socket.emit('singlePose', poseArr);
    return pose;
}

/**
 * Async recursive call that waits 33ms to update a pose prediction, for ~30fps
 */
async function predictionLoop() {
     // ~30 fps?
    setTimeout(()=>{
        estimatePose();
        predictionLoop();
    }, 33);
}

/**
 * @param {*} pose PoseNet single pose prediction 
 * @returns flattened array (length=51) of keypoints and confidence scores
 */
function unpackPose(pose) {
    let poseArr = []
    // console.log(pose.keypoints);
    for (let i = 0; i < 17; i++) {
        let keypoint = pose.keypoints[i];
        // console.log(keypoint);
        poseArr.push(keypoint.position.x / 1280.0); // Normalize for FaceTime HD Camera
        poseArr.push(keypoint.position.y / 720.0);  // Normalize for FaceTime HD Camera
        poseArr.push(keypoint.score);
    }
    // console.log(poseArr);
    return poseArr;
}

function begin() {
    // Give sketching script access to the canvas/posenet
    sketch.setCanvasAndPoseNet(canvas, posenet);
    // Begin infinite prediction loop
    setTimeout(predictionLoop, 1000);
    // mirror webcam video feed
    context.translate(canvas.width, 0);
    context.scale(-1,1);
}

begin();
