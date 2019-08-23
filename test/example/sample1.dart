

const String SAMPLE1 = """
     //vr=1;
    response = Map();
    "/";
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
      resp = invokeurl
      [
        url :url
        type :GET
        parameters:params
        connection:"onedrive21r"
      ];
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
      for each valuee in valuess
      {
        if(valuee.containsKey("file"))
        {
          //knowing that a file is there
          found = true;
          //format YYYY:MM:DDThh:mm::ssZ	
          lastModifiedDate = valuee.get("lastModifiedDateTime").replaceAll("T"," ").replaceAll("Z"," ").toDate();
          year = lastModifiedDate.getYear().toString();
          yearLength = year.length();
          lastModifiedDate = lastModifiedDate.getDay() + " " + lastModifiedDate.getDate().replaceFirst("(st|nd|rd|th)","").getAlpha() + " '" + year.subText(yearLength - 2,yearLength);
          //doing '1990'.subText(2,4) will also work but it will break once reach year 10000 
          tableData.add({"Name":"[" + valuee.get("name") + "](" + valuee.get("webUrl") + ") ","Last Modified":lastModifiedDate});
        }
      }
      if(!found)
      {
        response.put("text","No results found for *" + arguments.trim() + "*.");
        return response;
      }
      response.put("text","Search results of *" + arguments + "*.");
      //response.put("slides",{{"type":"table","title":" ","data":{"headers":{"Name","Last Modified"},"rows":tableData}}});
      //response.put("slides",{"type":"table","title":" ","data":{"headers":{"Name","Last Modified"},"rows":tableData}});
      return response; 
    } 
    selec = selections.get(0);
    id = selec.get("id");
    params = Map();
    params.put("select","name,lastModifiedDateTime,createdBy,@microsoft.graph.downloadUrl,webUrl,size");
    url = "https://graph.microsoft.com/v1.0/me/drive/items/" + id;
    resp = invokeurl
    [
      url :url
      type :GET
      parameters:params
      connection:"onedrive21r"
    ]; 
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
    webUrl = ifnull(resp.get("webUrl"),"https://www.zoho.com/cliq/");
    createdBy = if(resp.get("createdBy").get("user").get("displayName") == NULL," ","Created by " + resp.get("createdBy").get("user").get("displayName"));
    lastModifiedDate = resp.get("lastModifiedDateTime").replaceAll("T"," ").replaceAll("Z","").toDate();
    year = lastModifiedDate.getYear().toString();
    yearLength = year.length();
    lastModifiedDate = lastModifiedDate.getDay() + " " + lastModifiedDate.getDate().replaceFirst("(st|nd|rd|th)","").getAlpha() + " '" + year.subText(yearLength - 2,yearLength);
    response.put("text",createdBy + " \nLast Modified on " + lastModifiedDate + " \n");
    card = Map();
    card.put("title",title);
    thumbnailparams = Map();
    thumbnailparams.put("select","c1280x720"); 
    thumbnail = invokeurl
    [
      url :"https://graph.microsoft.com/v1.0/me/drive/items/" + id + "/thumbnails"
      type :GET
      parameters:thumbnailparams
      connection:"onedrive21r"
    ];
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
    if(!webUrl.equals("https://www.zoho.com/cliq/"))
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
    deleteButtonConfirm = {"title":"Delete file " + title,"description":"This file will be deleted and moved to trash in your OneDrive.","buttontext":"Delete"};
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

const String SAMPLE2 = """

    message = Map();
    cfNme = "";
    info cfNme;
    fType = options.get("type");
    shareChat = options.get("share");
    shareLink = options.get("link");
    memTyp = "";
    if(arguments.get(0) != null)
    {
      info "dg";
    }
    if(arguments.get(0) != null && fType == null && shareLink == null && shareChat == null)
    {
      if(arguments.toLowerCase().contains("doc"))
      {
        arguSize = arguments.lastIndexOf(".doc");
        memTyp = "application/vnd.google-apps.document";
      }
      else if(arguments.toLowerCase().contains("sheet"))
      {
        arguSize = arguments.lastIndexOf(".sheet");
        memTyp = "application/vnd.google-apps.spreadsheet";
      }
      else if(arguments.toLowerCase().contains("slide"))
      {
        arguSize = arguments.lastIndexOf(".slide");
        memTyp = "application/vnd.google-apps.presentation";
      }
      else if(!arguments.toLowerCase().contains("doc") && !arguments.toLowerCase().contains("sheet") && !arguments.toLowerCase().contains("slide"))
      {
        memTyp = "application/vnd.google-apps.document";
        arguSize = arguments.length();
      }
      arguSubstr = arguments.subString(0,arguSize);
      cfNme = arguSubstr;
    }
    else
    {
      if(arguments.get(0) == null)
      {
        cfNme = "Untitled";
      }
      else if(arguments.get(0) != null && fType == null)
      {
        share_check = arguments.get(0).contains("-share");
        link_check = arguments.get(0).contains("-link");
        if(share_check == true || link_check == true)
        {
          argu_real = arguments.get(0).toList("-").get(0);
          cfNme = argu_real.toList(".").get(0);
          real_name = argu_real.toList(".");
          real_name_len = real_name.size();
          info real_name_len;
          if(real_name_len == 1)
          {
            memTyp = "application/vnd.google-apps.document";
          }
          else if(real_name_len == 2)
          {
            type_here = argu_real.toList(".").get(1);
            info type_here;
            if(type_here == "doc ")
            {
              memTyp = "application/vnd.google-apps.document";
            }
            else if(type_here == "sheet ")
            {
              memTyp = "application/vnd.google-apps.spreadsheet";
            }
            else if(type_here == "slide ")
            {
              memTyp = "application/vnd.google-apps.presentation";
            }
          }
        }
      }
      else if(arguments.get(0) != null && fType != null)
      {
        info arguments.get(0);
        share_check = arguments.get(0).contains("-share");
        link_check = arguments.get(0).contains("-link");
        if(share_check == true || link_check == true)
        {
          info fType + "g";
          cfNme = arguments.get(0).toList("-").get(0);
          if(fType == "doc")
          {
            memTyp = "application/vnd.google-apps.document";
          }
          else if(fType == "sheet")
          {
            memTyp = "application/vnd.google-apps.spreadsheet";
          }
          else if(fType == "slide")
          {
            memTyp = "application/vnd.google-apps.presentation";
          }
        }
        else
        {
          cfNme = arguments.get(0);
          if(fType == "doc")
          {
            memTyp = "application/vnd.google-apps.document";
          }
          else if(fType == "sheet")
          {
            info "st";
            memTyp = "application/vnd.google-apps.spreadsheet";
          }
          else if(fType == "slide")
          {
            memTyp = "application/vnd.google-apps.presentation";
          }
        }
      }
    }
    info memTyp;
    setFileTypes = Map();
    setFileTypes.put("title",cfNme);
    setFileTypes.put("mimeType",memTyp);
    headersMp = Map();
    headersMp.put("Content-Type","application/json");
    editLink = response.getJson("alternateLink");
    file_Id = response.getJson("id");
    thumLink = response.get("thumbnailLink");
    file_name = response.get("title");
    ownerName = response.get("owners").getJSON("displayName");
    emailIdlist = List();
    info thumLink;
    if(shareChat == "")
    {
      userCnt = chat.get("userscount");
      users = chat.get("users");
      info "----- " + users;
      for each  members in users
      {
        usersMap = members.toMap();
        emailId = usersMap.get("email");
        if(emailId != zoho.loginuserid)
        {
          emailIdlist.add(emailId);
        }
      }
      for each  emailId in emailIdlist
      {
        permissions = Map();
        permissions.put("role","writer");
        permissions.put("type","user");
        permissions.put("value",emailId);
      }
    }
    else if(shareLink == "")
    {
      info "Called";
      permissions = Map();
      permissions.put("withLink","true");
      permissions.put("role","writer");
      permissions.put("type","anyone");
      info response;
    }
    anyoneLink = "https://drive.google.com/open?id=" + file_Id;
    buttonObj = Map();
    buttonObj.put("label","open");
    if(shareLink == "" || shareChat == "")
    {
      buttonObj.put("label","shared_link");
    }
    buttonObj.put("hint","Just click to open the file");
    buttonObj.put("type","+");
    clickObj = Map();
    clickObj.put("type","open.url");
    actionDataObj = Map();
    if(shareLink == "")
    {
      actionDataObj.put("web",anyoneLink);
    }
    else if(shareChat == "")
    {
      actionDataObj.put("web",editLink);
    }
    else
    {
      actionDataObj.put("web",editLink);
    }
    clickObj.put("data",actionDataObj);
    buttonObj.put("action",clickObj);
    buttonArray = List();
    buttonArray.add(buttonObj);
    if(memTyp.contains("document"))
    {
      thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-document.png";
    }
    else if(memTyp.contains("sheet"))
    {
      thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-sheet.png";
    }
    else if(memTyp.contains("presentation"))
    {
      thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-slide.png";
    }
    msgMp = Map();
    msgMp.put("title",file_name);
    msgMp.put("thumbnail",thumLink);
    msgMp.put("theme","7");
    message.put("text","by " + ownerName);
    message.put("card",msgMp);
    message.put("buttons",buttonArray);
    if(shareChat == "" || shareLink == "")
    {
      info message;
      zoho.chat.postToChat(chat.get("id"),message);
    }
    else
    {
      info message;
      return message;
    } 
    return Map(); 
""";

const String SAMPLE3 = """
  message  Map();
  if(arguments == "")
  {
    //message.put("text","Invalid input. Usage \"/stackoverflow content editable disabled after long time usage\"");
    return message;
  }
  //url = "https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=relevance&q=" + encodeUrl(arguments) + "&accepted=True&site=stackoverflow";
  //response = getUrl(url,{"Content-Encoding":"gzip"});
  // info response;
  itemslist = response.toMap().get("items");
  count = 0;
  /*response = "*Answers for `" + arguments + "`*\n"; */
  //indexes = {"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣"};
  for each item in itemslist
  {
    if(item.get("answer_count") == 1)
    {
      response = response + indexes.get(count) + "  [" + item.get("title") + "](" + item.get("link") + ")  -  _" + item.get("answer_count") + " answer_\n";
    }
    else
    {
      response = response + indexes.get(count) + "  [" + item.get("title") + "](" + item.get("link") + ")  -  _" + item.get("answer_count") + " answers_\n";
    }
    count = count + 1;
    if(count > 4)
    {
      break;
    }
  }
  message.put("text"response);
  return message;
""";