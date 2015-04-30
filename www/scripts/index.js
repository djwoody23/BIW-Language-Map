//-----

var videoPlayer = null;

//-----

var main;
var map;

//-----


function resizeMap ()
{
    var ratio = map.naturalWidth / map.naturalHeight;
    var ratio_parent = main.parentNode.offsetWidth / main.parentNode.offsetHeight;

    if (ratio_parent > ratio) /* WIDE */
    {
        main.style.width = 100 * ratio / ratio_parent + "%";
        main.style.height = "100%";
    }
    else /* TALL */
    {
        main.style.width = "100%";
        main.style.height = 100 * ratio_parent / ratio + "%";
    }
}

function initializeVideoButtons()
{
    var bs = document.getElementById('video-buttons');
    var buttons = bs.getElementsByTagName('div');
    var imagepath = bs.dataset.imagepath;
    var imageext = bs.dataset.imageext;
    var videopath = bs.dataset.videopath;
    var videoext = bs.dataset.videoext;

    function button_image(id)
    {
        return "url(" + imagepath + id + imageext + ")";
    };

    function button_click()
    {
        videoPlayer.play(videopath + this.id + videoext);
    };

    for (var i = 0; i < buttons.length; i++)
    {
        var button = buttons[i];
        button.style.backgroundImage = button_image(button.id);
        button.addEventListener("click", button_click);
    }
}

function initialize()
{
    main = document.getElementsByClassName('main')[0];
    map = document.getElementById('map');

    window.addEventListener("resize", resizeMap);
    resizeMap();

    videoPlayer = new VideoHelper("video");

    initializeVideoButtons();
}

onReadyEvent(initialize);
