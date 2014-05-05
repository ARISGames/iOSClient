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

            /* DEBUG - uncomment to use in browser without error */
            /*
            _ARIS.isCurrentlyCalling();
            if(req == "aris://inventory/get/" + 99999999)
                _ARIS.didUpdateItemQty(99999999,1);
            _ARIS.isNotCurrentlyCalling();
            //*/
        }
    }

    _ARIS.isNotCurrentlyCalling = function()
    {
        _ARIS.currentlyCalling = false;
        _ARIS.dequeueRequest();
    }

    _ARIS.closeMe             = function()                 { _ARIS.enqueueRequest("aris://closeMe"); }
    _ARIS.hideLeaveButton     = function()                 { _ARIS.enqueueRequest("aris://leaveButton/disable"); }
    _ARIS.exitToTab           = function(tab)              { _ARIS.enqueueRequest("aris://exitTo/tab/"+tab); }
    _ARIS.exitToScanner       = function(prompt)           { _ARIS.enqueueRequest("aris://exitTo/scanner/"+prompt); }
    _ARIS.exitToPlaque        = function(plaque_id)        { _ARIS.enqueueRequest("aris://exitTo/plaque/"+plaque_id); }
    _ARIS.exitToWebpage       = function(webpageId)        { _ARIS.enqueueRequest("aris://exitTo/webpage/"+webpageId); }
    _ARIS.exitToItem          = function(item_id)          { _ARIS.enqueueRequest("aris://exitTo/item/"+item_id); }
    _ARIS.exitToCharacter     = function(npc_id)           { _ARIS.enqueueRequest("aris://exitTo/character/"+npc_id); }
    _ARIS.prepareMedia        = function(media_id)         { _ARIS.enqueueRequest("aris://media/prepare/" + media_id); }
    _ARIS.playMedia           = function(media_id)         { _ARIS.enqueueRequest("aris://media/play/" + media_id); }
    _ARIS.playMediaAndVibrate = function(media_id)         { _ARIS.enqueueRequest("aris://media/playAndVibrate/" + media_id); }
    _ARIS.stopMedia           = function(media_id)         { _ARIS.enqueueRequest("aris://media/stop/" + media_id); }
    _ARIS.setMediaVolume      = function(media_id, volume) { _ARIS.enqueueRequest("aris://media/setVolume/" + media_id + "/" + volume); }
    _ARIS.getItemCount        = function(item_id)          { _ARIS.enqueueRequest("aris://inventory/get/" + item_id); }
    _ARIS.setItemCount        = function(item_id,qty)      { _ARIS.enqueueRequest("aris://inventory/set/" + item_id + "/" + qty); }
    _ARIS.giveItemCount       = function(item_id,qty)      { _ARIS.enqueueRequest("aris://inventory/give/" + item_id + "/" + qty); }
    _ARIS.takeItemCount       = function(item_id,qty)      { _ARIS.enqueueRequest("aris://inventory/take/" + item_id + "/" + qty); }
    _ARIS.getPlayer           = function()                 { _ARIS.enqueueRequest("aris://player"); } 

    //Call ARIS API directly (USE WITH CAUTION)
    _ARIS.callService = function(serviceName, callback, GETparams, POSTparams)
    {
        var ROOT_URL = "http://arisgames.org"
        var url;
        if(GETparams) url = ROOT_URL+'/server/json.php/v1.'+serviceName+GETparams;
        else          url = ROOT_URL+'/server/json.php/v1.'+serviceName;
    
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
            console.log("POSTparams:" + POSTparams);
            console.log("url:" + url);
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
    if(typeof(_ARIS.didUpdateItemQty) === 'undefined')
    {
        _ARIS.didUpdateItemQty = function(updatedItemId,qty)
        {
            alert("Item '"+updatedItemId+"' qty was updated to '"+qty+"'. Override ARIS.didUpdateItemQty(updatedItemId,qty) to handle this event however you want! (Or, just add 'ARIS.didUpdateItemQty = function(updatedItemId,qty){return;};' to your code to just get rid of this message)");
        }
    }

    if(typeof(_ARIS.didReceivePlayer) === 'undefined')
    {
        _ARIS.didReceivePlayer = function(player)
        {
            alert("The player's name is "+player.name+". Override ARIS.didReceivePlayer(player) to handle this event however you want! (Or, just add 'ARIS.didReceivePlayer = function(player){return;};' to your code to just get rid of this message)");
        }
    }

    if(typeof(_ARIS.hook) === 'undefined')
    {
        _ARIS.hook = function(paramsJSON)
        {
            alert("Just recieved a hook from ARIS with this information: '"+paramsJSON+"'. Override ARIS.hook(paramsJSON) to handle this event however you want! (Or, just add 'ARIS.hook = function(paramsJSON){return;};' to your code to just get rid of this message)");
        }
    }
    
    if(typeof(_ARIS.ready) === 'undefined')
    {
        _ARIS.ready = function()
        {
            return;
        }
    }

    if(typeof(_ARIS.callbacksEnabled) !== 'undefined' && !_ARIS.callbacksEnabled)
    {
      _ARIS.didUpdateItemQty = function(updatedItemId,qty) {};
      _ARIS.didReceivePlayer = function(player)            {};
      _ARIS.hook             = function(paramsJSON)        {};
    }

    return _ARIS;
}

if(typeof(ARIS) === 'undefined') var ARIS = ARISJS({});
else ARIS = ARISJS(ARIS);

ARIS.ready();
