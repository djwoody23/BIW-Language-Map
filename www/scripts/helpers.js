
//-----

function Exists(value)
{
    return value !== 'undefined';
};

var phonegap =
{
    enabled: false,
    platform:
    {
        id: "",
        android: false,
        ios: false,
        init: function()
        {
            console.log("INIT PHONEGAP PLATFORM");
            this.id = device.platform.toLowerCase();
            this.android = this.id == "android";
            this.ios = this.id == "ios";
        },
        media: function(src)
        {
            if (this.android)
            {
                return "file:///android_asset/www/" + src;
            }
            return src;
        }
    },
    init: function()
    {
        this.enabled = Exists(typeof(window.cordova));

        if (this.enabled)
        {
            console.log("INIT PHONEGAP");

            function initPlatform() { phonegap.platform.init(); };
            document.addEventListener("deviceready", initPlatform, false);
        }
    }
};

window.addEventListener('load', function() { phonegap.init() }, false);



function onReadyEvent(func)
{
    function init()
    {
        if (phonegap.enabled)
        {
            document.addEventListener("deviceready", func, false);
        }
        else
        {
            func();
        }
    };

    window.addEventListener('load', init, false);
}


// Fullscreen video player
var VideoHelper = function(id)
{
    this.id = id;
    this.initialize();
};

onReadyEvent(function()
{
    var useMobile = phonegap.enabled;
    var useVideoPlayer = useMobile && phonegap.platform.android && Exists(typeof(VideoPlayer));

    if (useVideoPlayer)
    {
        console.log("USING VIDEOPLAYER");

        VideoHelper.prototype.initialize = function ()
        {

        };

        VideoHelper.prototype.play = function (url)
        {
            VideoPlayer.play(phonegap.platform.media(url),
                {
                    volume: 1.0,
                    scalingMode: VideoPlayer.SCALING_MODE.SCALE_TO_FIT_WITH_CROPPING
                },
                function () { },
                function (err)
                {
                    console.log(err);
                }
            );
        };

        VideoHelper.prototype.pause = function ()
        {
            // CANNOT PAUSE
        };

        VideoHelper.prototype.stop = function ()
        {
            VideoPlayer.Close();
        };
    }
    else
    {
        VideoHelper.prototype.initialize = function ()
        {
            var createVideoElement = function(id)
            {
                var vid = document.getElementById(id);
                if (vid == null)
                {
                    vid = document.createElement("VIDEO");
                    vid.id = id;
                    vid.setAttribute("style", 'position: absolute; top: 0; left: 0; right: 0; bottom: 0; width: 100%; height: 100%; background-color: black; z-index: 999; display: none;');
                    document.getElementsByTagName("body")[0].appendChild(vid);
                }
                return vid;
            }

            this.video = createVideoElement(this.id);

            function videoShowHide(msg, show)
            {
                return function()
                {
                    if (msg != 'undefined') { console.log(msg); }
                    this.style.display = show ? "block" : "none";

                    if (show)
                    {
                        this.play();
                    }
                };
            }

            function showVideo(msg) { return videoShowHide(msg, true); };
            function hideVideo(msg) { return videoShowHide(msg, false); };

            this.video.addEventListener("canplay", showVideo("canplay"));
            this.video.addEventListener("ended", hideVideo("ended"));
            this.video.addEventListener("pause", hideVideo("pause"));
            this.video.addEventListener("error", hideVideo("error"));
            this.video.addEventListener("stalled", hideVideo("stalled"));

            var that = this;
            function stopVideo() { that.stop(); };
            if (useMobile)
            {
                document.addEventListener("backbutton", stopVideo, false);
            }
            //else
            {
                this.video.addEventListener("click", stopVideo);
            }
        };

        VideoHelper.prototype.play = function (url)
        {
            this.video.src = url;
            this.video.load();
        };

        VideoHelper.prototype.pause = function ()
        {
            this.video.pause();
        };

        VideoHelper.prototype.stop = function ()
        {
            this.pause();
        };
    }
}
);
