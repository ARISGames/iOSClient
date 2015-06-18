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
    _ARIS.getGroupItemCount   = function(item_id)          { _ARIS.enqueueRequest("aris://instances/group/get/" + item_id); }
    _ARIS.setGroupItemCount   = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/group/set/" + item_id + "/" + qty); }
    _ARIS.giveGroupItemCount  = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/group/give/" + item_id + "/" + qty); }
    _ARIS.takeGroupItemCount  = function(item_id,qty)      { _ARIS.enqueueRequest("aris://instances/group/take/" + item_id + "/" + qty); }
    _ARIS.getPlayer           = function()                 { _ARIS.enqueueRequest("aris://player"); }

    //Call ARIS API directly (USE WITH CAUTION)
    _ARIS.callService = function(serviceName, body, auth, callback)
    {
        var ROOT_URL = "http://arisgames.org"
        var url = ROOT_URL+'/server/json.php/v2.'+serviceName;

        var request = new XMLHttpRequest();
        request.onreadystatechange = function()
        {
            if(request.readyState == 4)
            {
                debugLog(request.responseText);
                if(request.status == 200)
                    callback(JSON.parse(request.responseText));
                else
                    callback(false);
            }
        };
        body.auth = auth;
        request.open('POST', url, true);
        request.setRequestHeader("Content-type","application/x-www-form-urlencoded");
        debugLog(JSON.stringify(body));
        request.send(JSON.stringify(body));
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
    if(!callbacks_enabled || typeof(_ARIS.didUpdateGroupItemQty)  === 'undefined') { _ARIS.didUpdateGroupItemQty  = function(updatedItemId,qty) {} }
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
      var cache_player = [];
      var cache_game = [];
      var cache_group = [];

      _ARIS.cache = {};
      _ARIS.cache.preload = function() {
        _ARIS.enqueueRequest("aris://cache/preload");
      };
      
      _ARIS.cache.getPlayerItemCount = function(item_id) { if(typeof(cache_player[item_id]) === 'undefined') return 0; return cache_player[item_id]; }
      _ARIS.cache.getGameItemCount   = function(item_id) { if(typeof(cache_game[item_id]) === 'undefined')   return 0; return cache_game[item_id]; }
      _ARIS.cache.getGroupItemCount  = function(item_id) { if(typeof(cache_group[item_id]) === 'undefined')  return 0; return cache_group[item_id]; }
      
      _ARIS.cache.setPlayerItem = function(item_id, qty) { cache_player[item_id] = qty; }
      _ARIS.cache.setGameItem   = function(item_id, qty) { cache_game[item_id]   = qty; }
      _ARIS.cache.setGroupItem  = function(item_id, qty) { cache_group[item_id]  = qty; }
      
      _ARIS.cache.setPlayer = function(player)
      {
        _ARIS.cache.player = player;
        _ARIS.cache.player.auth = {};
        _ARIS.cache.player.auth.user_id = _ARIS.cache.player.user_id;
        _ARIS.cache.player.auth.key = _ARIS.cache.player.key;
      };
      
      _ARIS.cache.detach = function()
      {
        _ARIS.cache.setPlayerItem = undefined;
        _ARIS.cache.setGameItem = undefined;
        _ARIS.cache.setGroupItem = undefined;
        _ARIS.ready();
      }

      _ARIS.cache.wholeCache = function() { return {"player":cache_player,"game":cache_game,"group":cache_group}; } //FOR DEBUGGING
    }
  
    /*
     * ARIS DEBUG LOG FUNCTIONS
     */
    var debugLog = function(str) { }
  
    var log_enabled = (typeof(_ARIS.debugLogEnabled) !== 'undefined' && _ARIS.debugLogEnabled);
    if(log_enabled)
    {
      var debug = document.createElement('div');
      debug.setAttribute("id","_ARIS_JS_DEBUG_LOG");
      debug.style.width = "100%";
      debug.style.height = "100%";
      debug.style.position = "absolute";
      debug.style.top = "0px";
      debug.style.left = "0px";
      debug.style.pointerEvents = "none";
      debug.style.wordWrap = "break-word";
      document.body.appendChild(debug);
      
      debugLog = function(str)
      {
        console.log(str);
        debug.innerHTML = str+"<br />"+debug.innerHTML;
      }
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
