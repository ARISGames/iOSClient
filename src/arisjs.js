var ARISJS = function(_ARIS)
{
    _ARIS.requestsQueue = new Array();
    _ARIS.currentlyCalling = false;

    _ARIS.enqueueRequest = function(nextRequest)
    {
        _ARIS.requestsQueue.push(nextRequest);
        if(!_ARIS.currentlyCalling)
        {
            _ARIS.currentlyCalling = true;
            _ARIS.dequeueRequest();
        }
    }

    _ARIS.isCurrentlyCalling = function()
    {
        _ARIS.currentlyCalling = true;
    }

    _ARIS.dequeueRequest = function()
    {
        if(_ARIS.requestsQueue.length)
        {
            var req = _ARIS.requestsQueue.shift();
            window.location = req;
        }
    }

    _ARIS.isNotCurrentlyCalling = function()
    {
        _ARIS.currentlyCalling = false;
        _ARIS.dequeueRequest();
    }

    //legacy
    _ARIS.closeMe             = function()                 { _ARIS.enqueueRequest("aris://exit"); }
    _ARIS.hideLeaveButton     = function()                 { }
    _ARIS.playMediaAndVibrate = function(media_id)         { }
    _ARIS.exitToCharacter     = function(dialog_id)        { _ARIS.enqueueRequest("aris://exit/character/"+dialog_id); }
    _ARIS.getItemCount        = function(item_id)          { _ARIS.enqueueRequest("aris://instances/player/get/" + item_id); }
    _ARIS.setItemCount        = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/player/set/" + item_id + "/" + qty); }
    _ARIS.giveItemCount       = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/player/give/" + item_id + "/" + qty); }
    _ARIS.takeItemCount       = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/player/take/" + item_id + "/" + qty); }

    _ARIS.logOut              = function()                 { _ARIS.enqueueRequest("aris://logout"); }
    _ARIS.exit                = function()                 { _ARIS.enqueueRequest("aris://exit"); }
    _ARIS.exitToTab           = function(tab)              { _ARIS.enqueueRequest("aris://exit/tab/"+tab); }
    _ARIS.exitToScanner       = function(prompt)           { _ARIS.enqueueRequest("aris://exit/scanner/"+prompt); }
    _ARIS.exitToPlaque        = function(plaque_id)        { _ARIS.enqueueRequest("aris://exit/plaque/"+plaque_id); }
    _ARIS.exitToWebpage       = function(webpageId)        { _ARIS.enqueueRequest("aris://exit/webpage/"+webpageId); }
    _ARIS.exitToItem          = function(item_id)          { _ARIS.enqueueRequest("aris://exit/item/"+item_id); }
    _ARIS.exitToDialog        = function(dialog_id)        { _ARIS.enqueueRequest("aris://exit/character/"+dialog_id); }
    _ARIS.exitGame            = function()                 { _ARIS.enqueueRequest("aris://exit/game/"); }
    _ARIS.prepareMedia        = function(media_id)         { _ARIS.enqueueRequest("aris://media/prepare/" + media_id); }
    _ARIS.playMedia           = function(media_id)         { _ARIS.enqueueRequest("aris://media/play/" + media_id); }
    _ARIS.stopMedia           = function(media_id)         { _ARIS.enqueueRequest("aris://media/stop/" + media_id); }
    _ARIS.setMediaVolume      = function(media_id, volume) { _ARIS.enqueueRequest("aris://media/setVolume/" + media_id + "/" + volume); }
    _ARIS.vibrate             = function()                 { _ARIS.enqueueRequest("aris://vibrate"); }
    _ARIS.getPlayerItemCount  = function(item_id)          { _ARIS.enqueueRequest("aris://instances/player/get/" + item_id); }
    _ARIS.setPlayerItemCount  = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/player/set/" + item_id + "/" + qty); }
    _ARIS.givePlayerItemCount = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/player/give/" + item_id + "/" + qty); }
    _ARIS.takePlayerItemCount = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/player/take/" + item_id + "/" + qty); }
    _ARIS.getGameItemCount    = function(item_id)          { _ARIS.enqueueRequest("aris://instances/game/get/" + item_id); }
    _ARIS.setGameItemCount    = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/game/set/" + item_id + "/" + qty); }
    _ARIS.giveGameItemCount   = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/game/give/" + item_id + "/" + qty); }
    _ARIS.takeGameItemCount   = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/game/take/" + item_id + "/" + qty); }
    _ARIS.getPlayer           = function()                 { _ARIS.enqueueRequest("aris://player"); }

    //Call ARIS API directly (USE WITH CAUTION)
    _ARIS.callService = function(serviceName, callback, GETparams, POSTparams)
    {
        var ROOT_URL = "http://arisgames.org"
        var url;
        if(GETparams) url = ROOT_URL+'/server/json.php/v2.'+serviceName+GETparams;
        else          url = ROOT_URL+'/server/json.php/v2.'+serviceName;

        var request = new XMLHttpRequest();
        request.onreadystatechange = function()
        {
            if(request.readyState == 4)
            {
                if(request.status == 200)
                    callback(request.responseText);
                else
                    callback(false);
            }
        };
        if(POSTparams)
        {
            request.open('POST', url, true);
            request.setRequestHeader("Content-type","application/x-www-form-urlencoded");
            request.send(POSTparams);
            //console.log("POSTparams:" + POSTparams);
            //console.log("url:" + url);
        }
        else
        {
            request.open('GET', url, true);
            request.send();
            console.log("GETurl:" + url);
        }
    }

    //Not ARIS related... just kinda useful
    _ARIS.parseURLParams = function(url)
    {
        var queryStart = url.indexOf("?") + 1;
        var queryEnd   = url.indexOf("#") + 1 || url.length + 1;
        var query      = url.slice(queryStart, queryEnd - 1);

        var params  = {};
        if (query === url || query === "") return params;
        var nvPairs = query.replace(/\+/g, " ").split("&");

        for(var i=0; i<nvPairs.length; i++)
        {
            var nv = nvPairs[i].split("=");
            var n  = decodeURIComponent(nv[0]);
            var v  = decodeURIComponent(nv[1]);
            if(!(n in params)) params[n] = [];
            params[n].push(nv.length === 2 ? v : null);
        }
        return params;
    }

    /*
     * ARIS CALLBACK FUNCTIONS
     */
    var callbacks_enabled = (typeof(_ARIS.callbacksEnabled)     === 'undefined' || _ARIS.callbacksEnabled);

    if(!callbacks_enabled || typeof(_ARIS.didUpdateItemQty)       === 'undefined') { _ARIS.didUpdateItemQty       = function(updatedItemId,qty) {} }
    if(!callbacks_enabled || typeof(_ARIS.didUpdatePlayerItemQty) === 'undefined') { _ARIS.didUpdatePlayerItemQty = function(updatedItemId,qty) {} }
    if(!callbacks_enabled || typeof(_ARIS.didUpdateGameItemQty)   === 'undefined') { _ARIS.didUpdateGameItemQty   = function(updatedItemId,qty) {} }
    if(!callbacks_enabled || typeof(_ARIS.didReceivePlayer)       === 'undefined') { _ARIS.didReceivePlayer       = function(player)            {} }
    if(!callbacks_enabled || typeof(_ARIS.hook)                   === 'undefined') { _ARIS.hook                   = function(paramsJSON)        {} }
    if(!callbacks_enabled || typeof(_ARIS.tick)                   === 'undefined') { _ARIS.tick                   = function(paramsJSON)        {} }
    if(                      typeof(_ARIS.ready)                  === 'undefined') { _ARIS.ready                  = function()                  {} }

    /*
     * ARIS CACHE FUNCTIONS (USER DO NOT TOUCH)
     */
    var cache_enabled = (typeof(_ARIS.dataCacheEnabled) !== 'undefined' && _ARIS.dataCacheEnabled);

    if(cache_enabled)
    {
      var cache_items = [];

      _ARIS.cache = {};
      _ARIS.cache.preload = function() {
        _ARIS.enqueueRequest("aris://cache/preload");
      };
      _ARIS.cache.getItemCount = function(item_id) { if(typeof(cache_items[item_id]) === 'undefined') return 0; return cache_items[item_id]; }
      _ARIS.cache.setItem = function(item_id, qty) { cache_items[item_id] = qty; }
      _ARIS.cache.detach = function() { _ARIS.cache.setItem = undefined; _ARIS.ready(); }

      _ARIS.cache.wholeCache = function() { return cache_items; } //FOR DEBUGGING
    }

    return _ARIS;
}

if(typeof(ARIS) === 'undefined') var ARIS = ARISJS({});
else
{
  if(typeof ARIS.dataCacheEnabled === 'undefined')
    ARIS.dataCacheEnabled = true;
  ARIS = ARISJS(ARIS);
}

if(ARIS.dataCacheEnabled) ARIS.cache.preload();
else ARIS.ready();
