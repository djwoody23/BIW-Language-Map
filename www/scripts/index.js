//-----

var videoPlayer = null;

//-----

var body;
var outer;
var main;
var map;

//-----

var pad = 0;    //PERCENT
var padding;
var ratio;

//-----


function resizeMap ()
{
    //outer.style.width = body.offsetWidth + "px";
    //outer.style.height = body.offsetHeight + "px";

    var w = main.parentNode.offsetWidth;// - padding;
    var h = main.parentNode.offsetHeight;// - padding;

    var ratio_parent = w / h;

    if (ratio_parent > ratio) /* WIDE */
    {
        //main.style.width = (h * ratio) + "px";
        //main.style.height = h + "px";
        main.style.width = 100 * ratio / ratio_parent + "%";
        main.style.height = "100%";
    }
    else /* TALL */
    {
        //main.style.width = w + "px";
        //main.style.height = (w / ratio) + "px";
        main.style.width = "100%";
        main.style.height = (w / h * 100) / ratio + "%";
    }

    console.log(main.offsetWidth + ", " + main.offsetHeight);
}

function initialize()
{
    body = document.getElementsByTagName("body")[0];
    outer = document.getElementsByClassName('outer')[0];
    main = document.getElementsByClassName('main')[0];
    map = document.getElementById('map');
    ratio = map.naturalWidth / map.naturalHeight;
    padding = pad * 2;

    videoPlayer = new VideoHelper("video");
    var buttons = document.getElementsByClassName('button-video');
    for (i = 0; i < buttons.length; i++)
    {
        buttons[i].addEventListener("click", function()
        {
            videoPlayer.play("videos/" + this.id + ".mp4");
        });
    }

    window.addEventListener("resize", resizeMap);
    resizeMap();
}

onReadyEvent(initialize);
