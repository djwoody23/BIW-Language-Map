
//-----

var cordova_enabled = false;
var cordova_platform = "";
var cordova_android = false;


function initializeCordova()
{
    if (typeof(window.cordova) !== 'undefined')
    {
        console.log("USING CORDOVA");

		cordova_enabled = true;
        cordova_platform = device.platform.toLowerCase();
        cordova_android = cordova_platform == "android";
    }
}

function onReadyEvent(func)
{
	function init()
	{
		initializeCordova();

		if (cordova_enabled)
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


//-----

function getMediaURL(s)
{
    if (cordova_android)
    {
        //return "android.resource://au.com.bundiyarra.map/raw/" + s;
        return "file:///android_asset/www/" + s;
    }
    return s;
}



// Fullscreen video player
var VideoHelper = function(id)
{
    if (cordova_android &&
        typeof(VideoPlayer) != 'undefined')
    {
        this.play = function (url)
        {
            VideoPlayer.play(getMediaURL(url),
                {
                    volume: 1.0,
                    scalingMode: VideoPlayer.SCALING_MODE.SCALE_TO_FIT
                },
                function ()
                {
                    console.log("video completed");
                },
                function (err)
                {
                    console.log(err);
                }
            );
        };

        this.pause = function ()
        {
        	// CANNOT PAUSE
        };

        this.stop = function ()
        {
            VideoPlayer.Close();
        };
    }
    else
    {
    	this.id = id;

    	var that = this;

    	var vid = document.createElement("VIDEO");
    	vid.id = id;
    	vid.setAttribute("style", 'position: absolute; top: 0; left: 0; right: 0; bottom: 0; width: 100%; height: 100%; background-color: black; z-index: 999; display: none;');

        function showVideo()
        {
            vid.style.display = "block";
        }
        function showVideoPlay()
        {
            showVideo();
            vid.play();
        }

        function hideVideo()
        {
            vid.style.display = "none";
        }
        function hideVideoLog(msg)
        {
            return function()
            {
                console.log(msg);
                hideVideo()
            };
        }

        vid.addEventListener("canplay", showVideoPlay);
        vid.addEventListener("ended", hideVideo);
        vid.addEventListener("pause", hideVideo);
        vid.addEventListener("error", hideVideoLog("error"));
        vid.addEventListener("stalled", hideVideoLog("stalled"));

        
        this.play = function (url)
        {
            vid.src = url;
            vid.load();
        };

        this.pause = function ()
        {
            vid.pause();
        };

        this.stop = function ()
        {
            that.pause();
            hideVideo();
        };

        if (cordova_android)
        {
            document.addEventListener("backbutton", function() { that.stop(); }, false);
        }
        else
        {
            vid.addEventListener("click", function() { that.stop(); });
        }

        document.getElementsByTagName("body")[0].appendChild(vid);
    }
};
