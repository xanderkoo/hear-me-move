const net = await posenet.load();
var currentPose = null;

/**
 * CAMERA STUFF
 */
// Code copied from https://stackoverflow.com/questions/32104975/html5-mirroring-webcam-canvas
// Grab elements, create settings, etc.
var canvas = document.getElementById("myCanvas"),
    context = canvas.getContext("2d"),
    // we don't need to append the video to the document
    video = document.createElement("video"),
    videoObj = 
    navigator.getUserMedia || navigator.mozGetUserMedia ? // our browser is up to date with specs ?
        { 
        video: {
            width: { min: 1280,  max: 1280 },
            height: { min: 720,  max: 720 },
            require: ['width', 'height']
            }
        } : {
        video: {
            mandatory: {
                minWidth: 1280,
                minHeight: 720,
                maxWidth: 1280,
                maxHeight: 720
            }
        }
},
errBack = function(error) {
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

function loop(){
    context.drawImage(video, crop.x, crop.y, crop.w, crop.h, 0, 0, canvas.width, canvas.height);
    raf = requestAnimationFrame(loop);
}

// now that our video is drawn correctly, we can do...
context.translate(canvas.width, 0);
context.scale(-1,1);


/**
 * POSENET STUFF
 */

var socket = io.connect('http://localhost:3000');

async function estimatePose(e) {
    const pose = await net.estimateSinglePose(canvas, {
        flipHorizontal: false
    });
    currentPose = pose;
    console.log(pose);
    let poseArr = unpackPose(pose);
    // Send this to local server
    socket.emit('singlePose', poseArr);
    return pose;
}

async function predictionLoop() {
     // ~10 fps?
    setTimeout(()=>{
        estimatePose();
        predictionLoop();
    }, 33);
}

// Begin infinite prediction loop
setTimeout(predictionLoop, 1000);

// document.onmousedown = estimatePose;

function unpackPose(pose) {
    let poseArr = []
    console.log(pose.keypoints);
    for (let i = 0; i < 17; i++) {
        let keypoint = pose.keypoints[i];
        console.log(keypoint);
        poseArr.push(keypoint.position.x / 1280.0); // Normalize for FaceTime HD Camera
        poseArr.push(keypoint.position.y / 720.0);  // Normalize for FaceTime HD Camera
        poseArr.push(keypoint.score);
    }
    // console.log(poseArr);
    return poseArr;
}

/**
 * nose
 * leftEye
 * rightEye
 * leftEar
 * rightEar
 * leftShoulder
 * rightShoulder
 * leftElbow
 * rightElbow
 * leftWrist
 * rightWrist
 * leftHip
 * rightHip
 * leftKnee
 * rightKnee
 * leftAnkle
 * rightAnkle
 */

