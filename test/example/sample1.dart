

const String SAMPLE1 = """
      //vr=1;
      response = Map();
      res = Collection();
      response.put("bot",{"name":"OneDrive"});
      if(arguments.trim().length() <= 0 && selections.size() <= 0)
      {
        response.put("text","Please enter a file name to look for in OneDrive.");
        return response;
      }
      if(selections.size() <= 0)
      {
        params = Map();
        params.put("select","name,webUrl,lastModifiedDateTime,file");
        params.put("top",5);
        //not sure on whether to encode search or not
        /*
        Hello 
        */
        url = "https://graph.microsoft.com/v1.0/me/drive/root/search(q='" + encodeurl(arguments.trim()) + "')";
        info resp;
        if(resp.containKey("error"))
        {
          response.put("text","Unable to look for files in OneDrive right now. :sad: \nPlease try again later.");
          return response;
        }
        valuess = resp.toMap().get("value");
        tableData = list();
        response.put("card",{"title":"File search","theme":"modern-inline"});
        found = false;
        for each  valuee in valuess
        {
          if(valuee.containsKey("file"))
          {
            //knowing that a file is there
            found = true;
            //format YYYY:MM:DDThh:mm::ssZ	
            lastModifiedDate = valuee.get("lastModifiedDateTime").replaceAll("T"," ").replaceAll("Z"," ").toDate();
            year = lastModifiedDate.getYear().toString();
            yearLength = year.length();
            //trips here
            //lastModifiedDate = lastModifiedDate.getDay() + " " + lastModifiedDate.getDate().replaceFirst("(st|nd|rd|th)","").getAlpha() + " '" + year.subText(yearLength - 2,yearLength);
            //doing '1990'.subText(2,4) will also work but it will break once reach year 10000 
            //tableData.add({"Name":"[" + valuee.get("name") + "](" + valuee.get("webUrl") + ") ","Last Modified":lastModifiedDate});
          }
        }
        //trips here with identifer in if and ! also
        //if(!found)
        if(valuee.containsKey("file"))
        {
          //trips here with multiple +
          //response.put("text","No results found for *" + arguments.trim() + "*.");
          return response;
        }
        //trips here with multiple +
        //response.put("text","Search results of *" + arguments + "*.");
        //response.put("slides",{{"type":"table","title":" ","data":{"headers":{"Name","Last Modified"},"rows":tableData}}});
        return response;
      }
      selec = selections.get(0);
      id = selec.get("id");
      params = Map();
      params.put("select","name,lastModifiedDateTime,createdBy,@microsoft.graph.downloadUrl,webUrl,size");
      url = "https://graph.microsoft.com/v1.0/me/drive/items/" + id;
      info resp;
      if(resp.containKey("error"))
      {
        return {"text":"Something went wrong :anxious: \n We are unable to get your file right now. Please try again later. ","bot":{"name":"OneDrive"}};
      }
      title = selec.get("title");
      if(title.length() >= 85)
      {
        title = title.subText(0,85);
      }
      //webUrl = ifnull(resp.get("webUrl"),"https://www.zoho.com/cliq/");
      //createdBy = if(resp.get("createdBy").get("user").get("displayName") == NULL," ","Created by " + resp.get("createdBy").get("user").get("displayName"));
      //lastModifiedDate = resp.get("lastModifiedDateTime").replaceAll("T"," ").replaceAll("Z","").toDate();
      year = lastModifiedDate.getYear().toString();
      yearLength = year.length();
      //lastModifiedDate = lastModifiedDate.getDay() + " " + lastModifiedDate.getDate().replaceFirst("(st|nd|rd|th)","").getAlpha() + " '" + year.subText(yearLength - 2,yearLength);
      //messes up commenting!!
      /*response.put("text",createdBy + " \nLast Modified on " + lastModifiedDate + " \n"); */
      card = Map();
      card.put("title",title);
      thumbnailparams = Map();
      thumbnailparams.put("select","c1280x720");
      info thumbnail;
      urlnear = thumbnail.get("value").toList();
      //If a preview is available
      if(urlnear.size() > 0)
      {
        card.put("thumbnail",urlnear.get(0).get("c1280x720").get("url"));
      }
      card.put("theme","modern-inline");
      response.put("card",card);
      buttons = List();
      //view button
      //if(!webUrl.equals("https://www.zoho.com/cliq/"))
      if(webUrl.equals("https://www.zoho.com/cliq/"))
      {
        viewButton = Map();
        viewButton.put("label","View");
        viewButton.put("arguments",{"id":id,"title":title});
        viewButton.put("action",{"type":"open.url","data":{"web":webUrl}});
        viewButton.put("type","+");
        buttons.add(viewButton);
      }
      //create link button
      downloadButton = Map();
      downloadButton.put("label","Download");
      downloadButton.put("arguments",{"id":id,"title":title});
      downloadButton.put("action",{"type":"open.url","data":{"web":resp.get("@microsoft.graph.downloadUrl")}});
      downloadButton.put("type","+");
      buttons.add(downloadButton);
      //delete button
      deleteButton = Map();
      deleteButton.put("label","Delete");
      deleteButton.put("arguments",{"id":id,"title":title});
      //tripping up
      //deleteButtonConfirm = {"title":"Delete file " + title,"description":"This file will be deleted and moved to trash in your OneDrive.","buttontext":"Delete"};
      deleteButton.put("action",{"type":"invoke.function","data":{"name":"DeleteAndShare"},"confirm":deleteButtonConfirm});
      deleteButton.put("type","-");
      buttons.add(deleteButton);
      //
      //keeping it dormnant as we have a lot of buttons
      versionButton = Map();
      versionButton.put("label","Version");
      versionButton.put("arguments",{"id":id,"title":title});
      versionButton.put("action",{"type":"invoke.function","data":{"name":"DeleteAndShare"}});
      versionButton.put("type","+");
      buttons.add(versionButton);
      //share button
      shareButton = Map();
      shareButton.put("label","Share");
      shareButton.put("arguments",{"id":id,"title":title,"size":resp.get("size").toNumber()});
      shareButton.put("action",{"type":"invoke.function","data":{"name":"DeleteAndShare"}});
      shareButton.put("type","+");
      buttons.add(shareButton);
      //
      response.put("buttons",buttons);
      return response;
""";