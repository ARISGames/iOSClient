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

    _ARIS.closeMe             = function()                { _ARIS.enqueueRequest("aris://closeMe"); }
    _ARIS.exitToTab           = function(tab)             { _ARIS.enqueueRequest("aris://exitTo/tab/"+tab); }
    _ARIS.exitToScanner       = function(prompt)          { _ARIS.enqueueRequest("aris://exitTo/scanner/"+prompt); }
    _ARIS.exitToPlaque        = function(plaqueId)        { _ARIS.enqueueRequest("aris://exitTo/plaque/"+plaqueId); }
    _ARIS.exitToWebpage       = function(webpageId)       { _ARIS.enqueueRequest("aris://exitTo/webpage/"+webpageId); }
    _ARIS.exitToItem          = function(itemId)          { _ARIS.enqueueRequest("aris://exitTo/item/"+itemId); }
    _ARIS.exitToCharacter     = function(characterId)     { _ARIS.enqueueRequest("aris://exitTo/character/"+characterId); }
    _ARIS.exitToPanoramic     = function(panoramicId)     { _ARIS.enqueueRequest("aris://exitTo/panoramic/"+panoramicId); }
    _ARIS.prepareMedia        = function(mediaId)         { _ARIS.enqueueRequest("aris://media/prepare/" + mediaId); }
    _ARIS.playMedia           = function(mediaId)         { _ARIS.enqueueRequest("aris://media/play/" + mediaId); }
    _ARIS.playMediaAndVibrate = function(mediaId)         { _ARIS.enqueueRequest("aris://media/playAndVibrate/" + mediaId); }
    _ARIS.stopMedia           = function(mediaId)         { _ARIS.enqueueRequest("aris://media/stop/" + mediaId); }
    _ARIS.setMediaVolume      = function(mediaId, volume) { _ARIS.enqueueRequest("aris://media/setVolume/" + mediaId + "/" + volume); }
    _ARIS.getItemCount        = function(itemId)          { _ARIS.enqueueRequest("aris://inventory/get/" + itemId); }
    _ARIS.setItemCount        = function(itemId,qty)      { _ARIS.enqueueRequest("aris://inventory/set/" + itemId + "/" + qty); }
    _ARIS.giveItemCount       = function(itemId,qty)      { _ARIS.enqueueRequest("aris://inventory/give/" + itemId + "/" + qty); }
    _ARIS.takeItemCount       = function(itemId,qty)      { _ARIS.enqueueRequest("aris://inventory/take/" + itemId + "/" + qty); }
    _ARIS.getPlayerName       = function()                { _ARIS.enqueueRequest("aris://player/name"); }
    _ARIS.setBumpString       = function(bString)         { _ARIS.enqueueRequest("aris://bump/"+bString); }

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
    if(!_ARIS.didUpdateItemQty)
    {
        _ARIS.didUpdateItemQty = function(updatedItemId,qty)
        {
            alert("Item '"+updatedItemId+"' qty was updated to '"+qty+"'. Override ARIS.didUpdateItemQty(updatedItemId,qty) to handle this event however you want! (Or, just add 'ARIS.didUpdateItemQty = function(updatedItemId,qty){return;};' to your code to just get rid of this message)");
        }
    }

    if(!_ARIS.didReceiveName)
    {
        _ARIS.didReceiveName = function(name)
        {
            alert("The player's name is "+name+". Override ARIS.didReceiveName(name) to handle this event however you want! (Or, just add 'ARIS.didReceiveName = function(name){return;};' to your code to just get rid of this messagea)");
        }
    }

    if(!_ARIS.bumpDetected)
    {
        _ARIS.bumpDetected = function(bumpString)
        {
            alert("Just detected a successful bump with this information: '"+bumpString+"'. Override ARIS.bumpReceived(bumpString) to handle this event however you want! (Or, just add 'ARIS.bumpReceived = function(bumpString){return;};' to your code to just get rid of this message)");
        }
    }

    if(!_ARIS.hook)
    {
        _ARIS.hook = function(paramsJSON)
        {
            alert("Just recieved a hook from ARIS with this information: '"+paramsJSON+"'. Override ARIS.hook(paramsJSON) to handle this event however you want! (Or, just add 'ARIS.hook = function(paramsJSON){return;};' to your code to just get rid of this message)");
        }
    }

    return _ARIS;
}

if(ARIS) ARISJS(ARIS);
else var ARIS = ARISJS({});

if(ARISReady) ARISReady();
