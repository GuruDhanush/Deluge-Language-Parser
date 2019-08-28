

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

const String SAMPLE2 = """message = Map();
    res = invokeurl
	  [
        url :1
        type : 1
        connection:1 
	  ];
    cfNme = "";
    """;
    var k = """info cfNme;
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

const String SAMPLE4 = """
  
// "addissue" Function to handle forms

//Form change handler

targetName = target.get("name");
inputValues = form.get("values");
option = List();
actions = list();
if(targetName.equalsIgnoreCase("portals"))
{
	portalID = inputValues.get("portals").get("value");
	res = invokeurl
	[
		url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/"
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(!res.get("projects").isEmpty())
	{
		projects = res.get("projects");
		for each  project in projects
		{
			entry = Map();
			entry.put("label",project.get("name"));
			entry.put("value",project.get("id"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"portals","input":{"type":"select","name":"project","label":"Project","hint":"All projects from the selected portal are listed here","placeholder":"Pick a project","mandatory":true,"value":"list","options":option,"trigger_on_change":true}});
	}
	else
	{
		actions.add({"type":"remove","name":"project"});
	}
}
return {"type":"form_modification","actions":actions};


// "addissue" Function to handle form functions
// Submit handler

response = Map();
portalID = form.get("values").get("portals").get("value");
projectID = form.get("values").get("project").get("value");
projectName = form.get("values").get("project").get("label");
title = form.get("values").get("title");
addIssue = invokeurl
[
	url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/" + projectID + "/bugs/?title=" + encodeUrl(title)
	type :POST
	connection:"ENTER YOUR CONNECTION NAME"
];
response = {"text":"successfully added a bug in *" + projectName + "* "};
return response;


// Code for message action to add an issue in Zoho Projects

form = Map();
description = message.get("text");
option = List();
inputs = List();
res = invokeurl
[
	url :"https://projectsapi.zoho.com/restapi/portals/"
	type :GET
	connection:"ENTER YOUR CONNECTION NAME"
];
if(!res.get("portals").isEmpty())
{
	portals = res.get("portals");
	for each  portal in portals
	{
		entry = Map();
		entry.put("label",portal.get("name"));
		entry.put("value",portal.get("id_string"));
		option.add(entry);
	}
	inputs.add({"type":"select","name":"portals","label":"Portals","trigger_on_change":true,"hint":"All projects from the default portal are listed here","placeholder":"Choose a portal","mandatory":true,"options":option});
	inputs.add({"type":"text","name":"title","label":"Title","hint":"Enter the issue name","placeholder":"Ex: Ryan's laptop isn't working","mandatory":true,"value":""});
	inputs.add({"type":"textarea","name":"description","label":"Description","hint":"Briefly describe the issue","max_length":1000,"placeholder":"IT-Support: Requests on device maintenance and software installation","mandatory":false,"value":description});
	form = {"type":"form","title":"Add Issue","hint":"Select the project into which you want to add the issue.","name":"add","version":1,"button_label":"Add","actions":{"submit":{"type":"invoke.function","name":"addissue"}},"inputs":inputs};
}
else
{
	return {"text":"Your account does not have any portals.\nDo try again after creating portals."};
}
return form;


// "addtask" Function to handle forms
//form change handler
targetName = target.get("name");
inputValues = form.get("values");
option = List();
actions = list();
if(targetName.equalsIgnoreCase("portals"))
{
	portalID = inputValues.get("portals").get("value");
	res = invokeurl
	[
		url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/"
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(!res.get("projects").isEmpty())
	{
		projects = res.get("projects");
		for each  project in projects
		{
			entry = Map();
			entry.put("label",project.get("name"));
			entry.put("value",project.get("id"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"portals","input":{"type":"select","name":"project","label":"Project","hint":"All projects from the selected portal are listed here","placeholder":"Pick a project","mandatory":true,"value":"list","options":option,"trigger_on_change":true}});
	}
	else
	{
		actions.add({"type":"remove","name":"project"});
	}
}
if(targetName.equalsIgnoreCase("project"))
{
	portalID = inputValues.get("portals").get("value");
	projectID = inputValues.get("project").get("value");
	res = invokeurl
	[
		url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/" + projectID + "/tasklists/?flag=internal"
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(!res.get("tasklists").isEmpty())
	{
		tasklists = res.get("tasklists");
		for each  tasklist in tasklists
		{
			entry = Map();
			entry.put("label",tasklist.get("name"));
			entry.put("value",tasklist.get("id"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"project","input":{"type":"select","name":"tasklist","label":"Task List","hint":"All task list of the selected project are listed here","placeholder":"Choose a task list","mandatory":true,"value":"list","options":option}});
	}
	else
	{
		actions.add({"type":"remove","name":"tasklist"});
	}
}
return {"type":"form_modification","actions":actions};


response = Map();
portalID = form.get("values").get("portals").get("value");
projectID = form.get("values").get("project").get("value");
tasklistID = form.get("values").get("tasklist").get("value");
projectName = form.get("values").get("project").get("label");
task_title = form.get("values").get("title");
addTask = invokeurl
[
	url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/" + projectID + "/tasks/?tasklist_id=" + tasklistID + "&name=" + encodeUrl(task_title)
	type :POST
	connection:"ENTER YOUR CONNECTION NAME"
];
response = {"text":"successfully added a task in *" + projectName + "* "};
return response;


// Code for message action to add an issue in Zoho Projects
form = Map();
desc = message.get("text");
option = List();
inputs = List();
res = invokeurl
[
	url :"https://projectsapi.zoho.com/restapi/portals/"
	type :GET
	connection:"ENTER YOUR CONNECTION NAME"
];
if(!res.get("portals").isEmpty())
{
	portals = res.get("portals");
	for each  portal in portals
	{
		entry = Map();
		entry.put("label",portal.get("name"));
		entry.put("value",portal.get("id_string"));
		option.add(entry);
	}
	inputs.add({"type":"select","name":"portals","label":"Portals","trigger_on_change":true,"hint":"All your active portals are listed here","placeholder":"Choose a portal","mandatory":true,"options":option});
	inputs.add({"type":"text","name":"title","label":"Title","hint":"Enter the task name","placeholder":"Ex: Update ZylCal home page","mandatory":true,"value":""});
	inputs.add({"type":"textarea","name":"description","label":"Description","hint":"Briefly describe the task","max_length":1000,"placeholder":"New UI changes abd functionalities are to be updated soon","mandatory":false,"value":desc});
	form = {"type":"form","title":"Add Task","hint":"Select the project into which you want to add a task.","name":"task","version":1,"button_label":"Add","actions":{"submit":{"type":"invoke.function","name":"addtask"}},"inputs":inputs};
}
else
{
	return {"text":"Your account does not have any portals.Do try again after creating portals"};
}
return form;



// /appear command execution code

appearMp = Map();
if(arguments == null || arguments == "")
{
	//appearRoom = user.getJSON("first_name") + " " + zoho.currenttime;
	appearRoom = "zohocliq-" + zoho.currenttime.toString("dd-MMM-yy hh:mm");
	//appearlink = "https://appear.in/"+user+ zoho.currenttime;
}
else
{
	appearRoom = arguments;
	//appearlink = "https://appear.in/" + arguments;
}
info appearRoom;
//ret.put("message", appearlink);
appearLink = "[" + appearRoom + "](https://appear.in/" + encodeURL(appearRoom) + ")";
message = Map();
//message.put("message","test");
message.put("text","*Join appeare* \n" + appearLink);
card = Map();
card.put("thumbnail","https://appear.in/images/favicon.png");
message.put("card",card);
// message.put("thumbnail_url","https://appear.in/images/favicon.png");
//a = zoho.chat.postToChat(chat.get("id"),message);
return message;





response = Map();
webhookBody = body.toMap();
info webhookBody;
events = webhookBody.get("events");
for each  event in events
{
	resourceId = event.get("resource");
	if(event.get("type") == "task" && event.get("action") == "added" || event.get("type") == "task" && event.get("action") == "changed")
	{
		assigneeId = "";
		taskInfo = invokeurl
		[
			url :"https://app.asana.com/api/1.0/tasks/" + resourceId
			type :GET
			connection:"{Your Connection Name}"
		];
		task = taskInfo.get("data");
		assignedTo = "None";
		taskName = task.get("name");
		if(taskName == "")
		{
			taskName = "None";
		}
		created = task.get("created_at").toDate();
		due = "-";
		if(task.get("due_on") != null)
		{
			due = task.get("due_on").toDate();
		}
		modified = task.get("modified_at").toDate();
		status = task.get("assignee_status");
		notes = task.get("notes");
		tags = task.get("tags");
		temp = "";
		for each  tag in tags
		{
			temp = temp + tag.get("name") + " ";
		}
		tags = temp;
		if(task.get("assignee") != null)
		{
			assignedTo = task.get("assignee").get("name");
			assigneeId = task.get("assignee").get("id");
		}
		else
		{
			assignedTo = "no one";
		}
		if(event.get("action") == "added")
		{
			info resourceId;
			response = {"text":"Task created and assigned to " + assignedTo,"card":{"theme":"modern-inline","title":"### " + taskName},"slides":{{"type":"label","data":{{"Created At":created},{"Due by":due},{"Last Modified on":modified},{"Assignee Status":status},{"Notes":notes},{"Tags":tags}}}}};
			zoho.cliq.postToBot("{Bot Name}", response);
		}
	}
}
return response;



response = Map();
	getProjects = invokeurl
	[
		url :"https://app.asana.com/api/1.0/projects"
		type :GET
		connection:"{Your Connection Name}"
	];
	info getProjects;
	projects = getProjects.get("data");
	for each  project in projects
	{
		projectId = project.get("id");
		params = Map();  params.put("target","https://cliq.zoho.com/api/v2/applications/{APPID}/incoming?zapikey={AUTHTOKEN}&appkey={APP_SECRET_KEY}");
		params.put("resource", projectId);
		webhooksCreate = invokeurl
		[
			url :"https://app.asana.com/api/1.0/webhooks"
			type :POST
			parameters:params
			connection:"{Your Connection Name}"
		];
		info webhooksCreate;
	}
return response;



workspaces = invokeurl
[
	url :"https://app.asana.com/api/1.0/workspaces"
	type :GET
	connection:"{Your Connection Name}"
];
workspaces = workspaces.get("data");
for each  workspace in workspaces
{
	workspaceId = workspace.get("id");
	webhooks = invokeurl
	[
		url :"https://app.asana.com/api/1.0/webhooks?workspace=" + workspaceId
		type :GET
		connection:"{Your Connection Name}"
	];
	webhooks = webhooks.get("data");
	for each  webhook in webhooks
	{
		if(webhook.get("target").contains("https://cliq.zoho.com/api/v2/applications/{APPID}"))
		{
			deleteWebhookId = webhook.get("id");
			deleteWebhook = invokeurl
			[
				url :"https://app.asana.com/api/1.0/webhooks/" + deleteWebhookId
				type :DELETE
				connection:"{Your Connection Name}"
			];
			info deleteWebhook;
		}
	}
}


message = Map();
response = getUrl("http://api.pearson.com/v2/dictionaries/laad3/entries?apikey=*INSERT_API_KEY*&headword=" + arguments.get(0).toLowerCase());
if(arguments.length() == 0)
{
	message.put("text","Please enter a word to find the meaning");
}
else if(response.get("results").length() != 0)
{
	results = response.get("results");
	loop = 0;
	count = -1;
	flag = 0;
	for each  temp in results
	{
		if(results.get(loop).get("headword") == arguments.get(0).toLowerCase() && flag == 0)
		{
			count = loop;
			flag = 1;
		}
		loop = loop + 1;
	}
	if(count != -1)
	{
		orginalText = response.get("results").get(count).get("senses").get(0).get("definition");
		definition = orginalText.subString(0,1);
		definition = definition.toUpperCase();
		definition = definition + orginalText.subString(1,orginalText.length());
		result = "Definition of *" + arguments.get(0) + "* : " + definition;
		example = response.get("results").get(count).get("senses").get(0);
		info response;
		if(example.size() == 2)
		{
			if(response.get("results").get(count).get("senses").get(0).get("examples").isNull() == false)
			{
				result = result + ". Example: " + response.get("results").get(count).get("senses").get(0).get("examples").get(0).get("text");
			}
		}
	}
	else
	{
		result = "Unable to find meaning for the word you have entered.";
	}
	message.put("text",result);
}
else
{
	message.put("text","Unable to find meaning for the word. Please check the spelling");
}
return message;

message = Map();
fortune = "[" + (getUrl("https://helloacm.com/api/fortune/")).replaceAll("\t","\\\t").replaceAll("\n","\\\n") + "]";
message.put("text",fortune.toList().get(0));
return message;

// Code for slash command to view files from zoho docs

form = Map();
option = List();
inputs = List();
folders = invokeurl
[
	url :"https://apidocs.zoho.com/files/v1/folders"
	type :GET
	connection:"ENTER YOUR CONNECTION NAME"
];
if(folders.get(0).get("SUCCESS") == "1")
{
	folders.remove(0);
	for each  folder in folders
	{
		entry = Map();
		entry.put("label",folder.get(0).get("FOLDER_NAME"));
		entry.put("value",folder.get(0).get("FOLDER_ID"));
		option.add(entry);
	}
	inputs.add({"type":"select","name":"folder","label":"Folders","trigger_on_change":true,"hint":"Choose a folder to view its subfolders","placeholder":"Choose a folder","mandatory":true,"value":"board","options":option});
	form = {"type":"form","title":"View files","hint":"View files from Zoho Docs by selecting a folder","name":"upload","version":1,"button_label":"View","actions":{"submit":{"type":"invoke.function","name":"viewdocs"}},"inputs":inputs};
}
return form;


// "viewdocs" Function to handle form functions
//form change handler

targetName = target.get("name");
inputValues = form.get("values");
option = List();
actions = list();
if(targetName.containsIgnoreCase("folder"))
{
	folderid = inputValues.get("folder").get("value");
	res = invokeurl
	[
		url :"https://apidocs.zoho.com/files/v1/folders?folderid=" + folderid
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(res.get("FOLDER").size() > 0)
	{
		sub_folder = res.get("FOLDER");
		for each  folder in sub_folder
		{
			entry = Map();
			entry.put("label",folder.get("FOLDERNAME"));
			entry.put("value",folder.get("FOLDERID"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"folder","input":{"type":"select","name":"subfolder","label":"Subfolder","hint":"Pick a subfolder to upload a file","placeholder":"Select a sub-folder","mandatory":true,"value":"list","options":option}});
	}
	else
	{
		actions.add({"type":"remove","name":"subfolder"});
	}
}
return {"type":"form_modification","actions":actions};



// "viewdocs" Function to handle form functions
// Submit handler

response = Map();
formValues = Map();
formValues = form.get("values");
if(form.get("name").equalsIgnoreCase("upload"))
{
	folder_id = formValues.get("folder").get("value");
	folder_name = formValues.get("folder").get("label");
	if(formValues.containsKey("subfolder"))
	{
		folder_id = formValues.get("subfolder").get("value");
	}
	res = invokeurl
	[
		url :"https://apidocs.zoho.com/files/v1/folders?folderid=" + folder_id
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(res.get("FILES").isEmpty())
	{
		return {"text":"No files  to display, the folder is empty."};
	}
	files = res.get("FILES");
	data = List();
	for each  file in files
	{
		file_name = "*" + file.get("DOCNAME") + "* created on _" + file.get("CREATED_TIME") + "_";
		data.add(file_name);
	}
	response = {"text":"Files form your *" + folder_name + "* folder\n","card":{"theme":"modern-inline"},"slides":{{"type":"list","title":"","data":data}}};
}
return response;



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
response = invokeurl
[
	url :"https://www.googleapis.com/drive/v2/files"
	type :POST
	parameters:setFileTypes.toString()
	headers:headersMp
	connection:"*INSERT_YOUR_CONNECTION_NAME*"
	useraccess:true
];
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
		response = invokeurl
		[
			url :"https://www.googleapis.com/drive/v2/files/" + file_Id + "/permissions"
			type :POST
			parameters:permissions.toString()
			headers:headersMp
			connection:"*INSERT_YOUR_CONNECTION_NAME*"
			useraccess:true
		];
	}
}
else if(shareLink == "")
{
	info "Called";
	permissions = Map();
	permissions.put("withLink","true");
	permissions.put("role","writer");
	permissions.put("type","anyone");
	response = invokeurl
	[
		url :"https://www.googleapis.com/drive/v2/files/" + file_Id + "/permissions"
		type :POST
		parameters:permissions.toString()
		headers:headersMp
		connection:"*INSERT_YOUR_CONNECTION_NAME*"
		useraccess:true
	];
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

message = Map();
info "ram";
info arguments;
info "slc" + selections.get(0);
shareChat = options.get("share");
shareLink = options.get("link");
if(selections == null)
{
	info "yes";
	headersMp = Map();
	headersMp.put("Content-Type","application/json");
	Nme = '';
	response = invokeurl
	[
		url :"https://content.googleapis.com/drive/v2/files?q=fullText%20contains%20%27" + Nme + "%27%20and%20trashed%20%3D%20false&maxResults=5"
		type :GET
		headers:headersMp
		connection:"*INSERT_YOUR_CONNECTION_NAME*"
		useraccess:true
	];
	info response;
	if(response != null)
	{
		jsn = response.getJSON("items").toJSONList();
		anyoneLink = "https://drive.google.com/open?id=";
		frwdMsgAry = List();
		if(jsn != null && !jsn.isEmpty())
		{
			for each  recordlst in jsn
			{
				rec_map = recordlst.toMap();
				//info rec_map;
				//tmp_Map = rec_map;
				mime_type = rec_map.get("mimeType");
				iconLink = rec_map.get("iconLink");
				file_id = rec_map.get("id");
				file_name = rec_map.get("title");
				ownerName = rec_map.get("owners").getJSON("displayName");
				editLink = rec_map.get("alternateLink");
				thumLink = rec_map.get("thumbnailLink");
				info file_id;
				frwdMsgObj = Map();
				frwdMsgObj.put("type","text");
				frwdMsgObj.put("title","[" + file_name + "](" + editLink + ")");
				frwdMsgObj.put("data","Author : " + ownerName);
				buttonObj = Map();
				buttonObj.put("text","Open");
				buttonObj.put("hint","Just click to open the file");
				buttonObj.put("type","ok");
				clickObj = Map();
				clickObj.put("action.type","open.url");
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
				clickObj.put("action.data",actionDataObj);
				buttonObj.put("click",clickObj);
				buttonAry = List();
				frwdmsgAry = List();
				buttonAry.add(buttonObj);
				frwdMsgObj.put("buttons",buttonAry);
				frwdmsgAry.add(frwdMsgObj);
				if(thumLink == null)
				{
					if(mime_type.contains("folder"))
					{
						thumLink = "";
					}
					else if(mime_type.contains("document"))
					{
						thumLink = "";
					}
					else if(mime_type.contains("spreadsheet"))
					{
						thumLink = "";
					}
					else if(mime_type.contains("presentation"))
					{
						thumLink = "";
					}
				}
			}
			message.put("message.thumbnail.url",thumLink);
			message.put("message.text","List of google drive files.");
			message.put("message.title","Drive Files");
			message.put("message.formatted",frwdmsgAry);
			zoho.chat.postToChat(chat.get("chatid"),message);
		}
	}
	else
	{
		message.put("text","Please enter the file name.(Hint:-s)");
		return message;
	}
}
else
{
	info "va";
	elem = selections.get(0);
	//imageurl = elem.get("imageurl");
	headersMp = Map();
	headersMp.put("Content-Type","application/json");
	file_name = elem.get("title");
	file_details = invokeurl
	[
		url :"https://content.googleapis.com/drive/v2/files?q=fullText%20contains%20%27" + encodeUrl(file_name) + "%27%20and%20trashed%20%3D%20false&maxResults=1"
		type :GET
		headers:headersMp
		connection:"*INSERT_YOUR_CONNECTION_NAME*"
		useraccess:true
	];
	mime = file_details.get("items").get(0).get("mimeType");
	file_Id = elem.get("id");
	docu_check = mime.contains("document");
	sheet_check = mime.contains("spreadsheet");
	slide_check = mime.contains("presentation");
	if(docu_check == true)
	{
		editLink = "https://docs.google.com/document/d/" + file_Id + "/edit?usp=drivesdk";
	}
	if(sheet_check == true)
	{
		editLink = "https://docs.google.com/spreadsheets/d/" + file_Id + "/edit#gid=0";
	}
	if(slide_check == true)
	{
		editLink = "https://docs.google.com/presentation/d/" + file_Id + "/edit#slide=id.p";
	}
	ownerName = elem.get("description");
	thumLink = elem.get("imageurl");
	//info thumLink.indexOf("FILE TYPE");
	emailIdlist = List();
	headersMp = Map();
	headersMp.put("Content-Type","application/json");
	info "THUM : " + thumLink;
	if(shareChat == "")
	{
		userCnt = chat.get("userscount");
		users = chat.get("users");
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
			response = invokeurl
			[
				url :"https://www.googleapis.com/drive/v2/files/" + file_Id + "/permissions"
				type :POST
				parameters:permissions.toString()
				headers:headersMp
				connection:"*INSERT_YOUR_CONNECTION_NAME*"
				useraccess:true
			];
			//info response;
		}
	}
	else if(shareLink == "")
	{
		//info "Called";
		permissions = Map();
		permissions.put("role","writer");
		permissions.put("type","anyone");
		permissions.put("withLink",true);
		response = invokeurl
		[
			url :"https://www.googleapis.com/drive/v2/files/" + file_Id + "/permissions"
			type :POST
			parameters:permissions.toString()
			headers:headersMp
			connection:"*INSERT_YOUR_CONNECTION_NAME*"
			useraccess:true
		];
		//info "Share any one response  :::::: " + response;
	}
	anyoneLink = "https://drive.google.com/open?id=" + file_Id;
	//openLink = "https://docs.google.com/document/d/"+file_Id1+"/edit?usp=drivesdk";
	buttonObj = Map();
	buttonObj.put("label","Open");
	if(shareLink != null && shareLink != "" || shareChat != null && shareChat != "")
	{
		info "ammu";
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
	butnAry = List();
	buttonObj.put("action",clickObj);
	butnAry.add(buttonObj);
	//info thumLink;
	/*if(thumLink == null)
	{
		thumLink = "https://drive-thirdparty.googleusercontent.com/128/type/application/octet-stream";
	}*/
	/*if(thumLink.contains("document") && thumLink.contains("FILE TYPE"))
			{
				thumLink = "https://drive-thirdparty.googleusercontent.com/128/type/application/octet-stream";
			}
			else if(thumLink.contains("sheet") && thumLink.contains("FILE TYPE"))
			{
				thumLink = "http://icons.iconarchive.com/icons/alecive/flatwoken/64/Apps-Google-Drive-Sheets-icon.png";
			}
			else if(thumLink.contains("presentation") && thumLink.contains("FILE TYPE"))
			{
				thumLink = "http://icons.iconarchive.com/icons/alecive/flatwoken/72/Apps-Google-Drive-Slides-icon.png";
			}
			else
			{
				thumLink = "https://drive-thirdparty.googleusercontent.com/128/type/application/octet-stream";
			}*/
	//}
	info "-------    " + thumLink;
	msgMp = Map();
	msgMp.put("title",file_name);
	msgMp.put("thumbnail",thumLink);
	msgMp.put("theme","7");
	message.put("text","by " + ownerName);
	message.put("card",msgMp);
	message.put("buttons",butnAry);
	// 	message.put("theme","7");
	//info message;
	if(shareLink == "" || shareChat == "")
	{
		zoho.chat.postToChat(chat.get("id"),message);
		file_type = selections;
		info "ft" + file_type;
	}
	else
	{
		//info "ELSE : " + message;
		file_type = selections;
		info "ft" + file_type;
		return message;
	}
	//}
}
return Map();


message = Map();
thumnailImg = options.get("img");
Nme = encodeUrl(arguments);
info Nme;
headersMp = Map();
headersMp.put("Content-Type","application/json");
response = invokeurl
[
	url :"https://content.googleapis.com/drive/v2/files?q=fullText%20contains%20%27" + Nme + "%27&maxResults=5"
	type :GET
	headers:headersMp
	connection:"*INSERT_YOUR_CONNECTION_NAME*"
	useraccess:true
];
//and%20trashed%20%3D%20true
info response;
list = List();
if(response != null)
{
	jsn = response.getJSON("items").toJSONList();
	info jsn;
	if(jsn != null && !jsn.isEmpty())
	{
		for each  recordlst in jsn
		{
			rec_map = recordlst.toMap();
			//info rec_map;
			//tmp_Map = rec_map;
			mime_type = rec_map.get("mimeType");
			iconLink = rec_map.get("iconLink");
			file_id = rec_map.get("id");
			file_name = rec_map.get("title");
			ownerName = rec_map.get("owners").getJSON("displayName");
			editLink = rec_map.get("alternateLink");
			thumLink = rec_map.get("thumbnailLink");
			info file_id;
			//info ownerName+" & " + file_name + " & " + mime_type + " & " + file_id;
			entry = Map();
			entry.put("title",file_name);
			entry.put("description",ownerName);
			if(thumLink != null)
			{
				entry.put("imageurl",thumLink);
			}
			else
			{
				if(mime_type.contains("document"))
				{
					thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-document.png";
				}
				else if(mime_type.contains("spreadsheet"))
				{
					thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-sheet.png";
				}
				else if(mime_type.contains("presentation"))
				{
					thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-slide.png";
				}
				else if(mime_type.contains("folder"))
				{
					thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-folder.png";
				}
				else
				{
					thumLink = "https://www.zoho.com/extensions/images/cliq/gdrive-file.png";
				}
				entry.put("imageurl",thumLink);
			}
			entry.put("id",file_id);
			list.add(entry);
		}
	}
}
return list;

text = Map();
if(arguments == "")
{
	text.put("message","Invalid input.");
	return text;
}
else
{
	headersMp = Map();
	setFileTypes = Map();
	setFileTypes.put("shortUrl",arguments);
	headersMp.put("Content-Type","application/json");
	url = "https://www.googleapis.com/urlshortener/v1/url?key=*Insert_API_Key*&shortUrl=" + encodeUrl(arguments);
	response = getUrl(url,{"Content-Type":"application/json"});
	styles = Map();
	styles.put("highlight","true");
	text.put("styles",styles);
	if(response.get("longUrl") == null)
	{
		text.put("text","Incorrect ShortURL - Enter Valid URL");
	}
	else
	{
		text.put("text","Long Url \n" + response.get("longUrl"));
	}
	return text;
}


text = Map();
if(arguments == "")
{
	text.put("text","Invalid input.");
	return text;
}
else
{
	headersMp = Map();
	setFileTypes = Map();
	setFileTypes.put("longUrl",arguments);
	headersMp.put("Content-Type","application/json");
	response = invokeurl
	[
		url :"https://www.googleapis.com/urlshortener/v1/url?key=*Insert_API_Key*"
		type :POST
		parameters:setFileTypes.toString()
		headers:headersMp
	];
	styles = Map();
	styles.put("highlight","true");
	text.put("styles",styles);
	if(response.get("id") == null)
	{
		text.put("text","Invalid URL");
	}
	else
	{
		text.put("text","Short Url \n" + response.get("id"));
	}
	return text;
}


message = Map();
key = options.get("key");
msg = options.get("msg");
if(key == null)
{
	message.put("text","Oops! You forgot to specify the key to mask the message.");
	return message;
}
if(msg == null)
{
	msg = arguments;
}
if(msg.length() > 0)
{
	encryptmsg = zoho.encryption.aesEncode(key,msg);
	message.put("text",encryptmsg);
}
else
{
	message.put("text","Wups! Looks like you forgot to mention the message you wish to mask & send");
}
return message;

message = Map();
key = options.get("key");
msg = options.get("msg");
decryptmsg = "";
if(key == null)
{
	message.put("text","Oops! You forgot to mention the key to reveal the message.");
	return message;
}
if(msg == null)
{
	msg = "" + arguments;
}
if(msg.length() > 0)
{
	msg = msg.trim();
	decryptmsg = zoho.encryption.aesDecode(key,msg);
	message.put("text",decryptmsg);
}
else
{
	message.put("text","Wups! Looks like you forgot to mention the masked message you wish to reveal");
}
return message;

message = Map();
if(arguments == "")
{
	message.put("text","Invalid input. Usage \"/stackoverflow content editable disabled after long time usage\"");
	return message;
}
url = "https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=relevance&q=" + encodeUrl(arguments) + "&accepted=True&site=stackoverflow";
response = getUrl(url,{"Content-Encoding":"gzip"});
// info response;
itemslist = response.toMap().get("items");
count = 0;
response = "*Answers for `" + arguments + "`*\n";
indexes = {"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣"};
for each  item in itemslist
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
message.put("text",response);
return message;

message = Map();
if(selections.isEmpty())
{
	if(arguments == null)
	{
	}
	url = "http://api.tenor.co/v1/search?tag=" + encodeUrl(arguments) + "&limit=2&locale=en&key=*Insert_API_Key*";
	response = getUrl(url);
	results = response.toMap().get("results");
	if(results.size() > 0)
	{
		result1 = results.get(0);
		media = result1.get("media");
		mediaelem = media.get(0);
		msg = mediaelem.get("gif");
		httpurl = msg.get("url");
		img = "https" + httpurl.subString(4,httpurl.length());
		message.put("message","Giphy for " + arguments);
		img = msg.get("url");
		message.put("message.text",msg.get("url"));
		message.put("imageurl",msg.get("url"));
	}
	else
	{
		img = "https://tenor.com/view/printer-waiting-dyno-results-nope-shredder-gif-4843044";
	}
}
else
{
	img = selections.get(0).get("imageurl");
}
message = Map();
aa = zoho.chat.postToChat(chat.get("id"),img);
return message;

message = Map();
url = "http://api.tenor.co/v1/search?tag=" + encodeUrl(arguments) + "&limit=25&locale=en&key=*Insert_API_Key*";
response = getUrl(url);
results = response.toMap().get("results");
i = 0;
if(!results.isEmpty())
{
	list = List();
	//info results1;
	for each  val in results
	{
		result1 = results.get(i);
		entry = Map();
		media = result1.get("media");
		mediaelem = media.get(0);
		msg = mediaelem.get("gif");
		message.put("message.text",msg.get("url"));
		httpurl = msg.get("url");
		httpsurl = "https" + httpurl.subString(4,httpurl.length());
		entry.put("imageurl",httpsurl);
		list.add(entry);
		i = i + 1;
	}
}
else
{
	return List();
}
//message=response;
return list;



// Code for message action to view an issue in Zoho Projects
form = Map();
option = List();
inputs = List();
res = invokeurl
[
	url :"https://projectsapi.zoho.com/restapi/portals/"
	type :GET
	connection:"ENTER YOUR CONNECTION NAME"
];
if(!res.get("portals").isEmpty())
{
	portals = res.get("portals");
	for each  portal in portals
	{
		entry = Map();
		entry.put("label",portal.get("name"));
		entry.put("value",portal.get("id_string"));
		option.add(entry);
	}
	inputs.add({"type":"select","name":"portals","label":"Portals","trigger_on_change":true,"hint":"All the user portals are displayed here","placeholder":"Choose a portal","mandatory":true,"options":option});
	form = {"type":"form","title":"Get Issues","hint":"Select the project to view its issues","name":"view","version":1,"button_label":"View","actions":{"submit":{"type":"invoke.function","name":"viewissues"}},"inputs":inputs};
}
else
{
	return {"text":"Your account does not have any portals.Do try again after creating portals"};
}
return form;


// "viewissues" Function to handle forms
// form change handler
targetName = target.get("name");
inputValues = form.get("values");
option = List();
actions = list();
if(targetName.equalsIgnoreCase("portals"))
{
	portalID = inputValues.get("portals").get("value");
	res = invokeurl
	[
		url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/"
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(!res.get("projects").isEmpty())
	{
		projects = res.get("projects");
		for each  project in projects
		{
			entry = Map();
			entry.put("label",project.get("name"));
			entry.put("value",project.get("id"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"portals","input":{"type":"select","name":"project","label":"Project","hint":"Projects associated with portal are listed here","placeholder":"Pick a project","mandatory":true,"value":"list","options":option,"trigger_on_change":true}});
	}
	actions.add({"type":"remove","name":"tasklist"});
	actions.add({"type":"remove","name":"task"});
}
if(targetName.equalsIgnoreCase("project"))
{
	portalID = inputValues.get("portals").get("value");
	projectID = inputValues.get("project").get("value");
	res = invokeurl
	[
		url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/" + projectID + "/bugs/"
		type :GET
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(!res.get("bugs").isEmpty())
	{
		bugs = res.get("bugs");
		for each  bug in bugs
		{
			entry = Map();
			entry.put("label",bug.get("title"));
			entry.put("value",bug.get("id"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"project","input":{"type":"select","name":"issue","label":"Issues","hint":"All issues of the selected project are listed here","placeholder":"Select an issue","mandatory":true,"value":"list","options":option}});
	}
}
return {"type":"form_modification","actions":actions};


response = Map();
formValues = form.get("values");
if(!formValues.containsKey("project"))
{
	return {"text":"Looks like you haven't created any projects in this portal. Do try again after creating one."};
}
if(!formValues.containsKey("issue"))
{
	return {"text":":sad: You haven't created any tasks in this list. Do try again after creating one."};
}
portalID = formValues.get("portals").get("value");
projectID = formValues.get("project").get("value");
issueID = formValues.get("issue").get("value");
res = invokeurl
[
	url :"https://projectsapi.zoho.com/restapi/portal/" + portalID + "/projects/" + projectID + "/bugs/" + issueID + "/"
	type :GET
	connection:"ENTER YOUR CONNECTION NAME"
];
bugDetails = res.get("bugs").get(0);
due_date = "None";
if(bugDetails.containsKey("due_date"))
{
	due_date = bugDetails.get("due_date");
}
severity = bugDetails.get("severity").get("type");
issue_name = bugDetails.get("title");
issue_key = bugDetails.get("key");
created_on = bugDetails.get("created_time");
status = bugDetails.get("status").get("type");
assignee = bugDetails.get("assignee_name");
response = {"text":"*" + issue_key + " " + issue_name + "*","card":{"title":"","theme":"modern-inline"},"slides":{{"type":"list","title":"","data":{"*Status :* " + status,"*Assignee name :* " + assignee,"*Created on :* " + created_on,"*Due Date :* " + due_date,"*Severity :* " + severity}}}};
return response;


// Code for slash command to view a user's tickets from zoho desk
form = Map();
option = List();
inputs = List();
res = invokeurl
[
	url :"https://desk.zoho.com/api/v1/organizations"
	type :GET
	connection:"ENTER YOUR CONNECTION NAME"
];
organizations = res.get("data");
if(organizations.size() > 0)
{
	for each  organization in organizations
	{
		entry = Map();
		entry.put("label",organization.get("organizationName"));
		entry.put("value",organization.get("id"));
		option.add(entry);
	}
	inputs.add({"type":"select","name":"org","label":"Organization","trigger_on_change":true,"hint":"Choose an organization to view your tickets","placeholder":"Choose an org","mandatory":true,"value":"org","options":option});
	form = {"type":"form","title":"View Ticket","hint":"View ticket details from Zoho Desk by choosing a ticket","name":"view","version":1,"button_label":"View","actions":{"submit":{"type":"invoke.function","name":"viewticket"}},"inputs":inputs};
}
return form;


// "viewticket" Function to handle form functions
//form change handler
targetName = target.get("name");
inputValues = form.get("values");
option = List();
actions = list();
if(targetName.equalsIgnoreCase("org"))
{
	orgID = inputValues.get("org").get("value");
	res = invokeurl
	[
		url :"https://desk.zoho.com/api/v1/departments"
		type :GET
		headers:{"orgId":orgID}
		connection:"ENTER YOUR CONNECTION NAME"
	];
	if(res.get("data").size() > 0)
	{
		departments = res.get("data");
		for each  department in departments
		{
			entry = Map();
			entry.put("label",department.get("name"));
			entry.put("value",department.get("id"));
			option.add(entry);
		}
		actions.add({"type":"add_after","name":"org","input":{"type":"select","name":"dept","label":"Department","hint":"Pick a department to view your tickets","placeholder":"Pick a department","mandatory":true,"value":"dept","options":option}});
	}
	else
	{
		actions.add({"type":"remove","name":"dept"});
	}
}
return {"type":"form_modification","actions":actions};


// "viewticket" Function to handle forms
// Submit handler
response = Map();
formValues = Map();
formValues = form.get("values");
if(!formValues.containsKey("dept"))
{
	return {"text":"Your org does not have any active department. Try again after creating one"};
}
orgID = formValues.get("org").get("value");
deptID = formValues.get("dept").get("value");
deptName = formValues.get("dept").get("label");
res = invokeurl
[
	url :"https://desk.zoho.com/api/v1/myinfo"
	type :GET
	headers:{"orgId":orgID}
	connection:"ENTER YOUR CONNECTION NAME"
];
myID = res.get("id");
res = invokeurl
[
	url :"https://desk.zoho.com/api/v1/tickets?departmentIds=" + deptID + "&assignee=" + myID
	type :GET
	headers:{"orgId":orgID}
	connection:"ENTER YOUR CONNECTION NAME"
];
info res;
if(res.get("data").size() > 0)
{
	tickets = res.get("data");
	rows = List();
	for each  ticket in tickets
	{
		item = Map();
		item.put("Ticket Number",ticket.get("ticketNumber"));
		if(ticket.get("dueDate").isNull())
		{
			item.put("Due Date","-");
		}
		else
		{
			item.put("Due Date",ticket.get("dueDate").toDate());
		}
		item.put("View Ticket","[view](" + ticket.get("webUrl") + ")");
		rows.add(item);
	}
}
else
{
	return {"text":"There are no tickets assigned for you in this department :smile:"};
}
response = {"text":"Tickets assigned for you in *" + deptName + "*","card":{"theme":"modern-inline"},"slides":{{"type":"table","title":"","data":{"headers":{"Ticket Number","Due Date","View Ticket"},"rows":rows}}}};
return response;


message = Map();
finalResponse = "";
if(!arguments.contains(" in "))
{
	finalResponse = "In order to search Yelp, please follow this format:\n/yelp *type of food* in *location*";
}
else
{
	getIn = arguments.indexOf(" in ");
	term = arguments.substring(0,getIn);
	location = arguments.subString(getIn + 5,arguments.length());
	response = invokeurl
	[
		url :"https://api.yelp.com/v3/businesses/search"
		type :GET
		parameters:{"term":term,"location":location,"limit":5}
		connection:"INSERT_CONNECTION_NAME"
	];
	info response;
	if(response.contains("error"))
	{
		err = response.get("error");
		if(err.get("code") == "LOCATION_NOT_FOUND")
		{
			finalResponse = "Error: Location is not compatible with Yelp yet, please enter a different location.";
		}
	}
	else
	{
		business = response.getJSON("businesses").toJSONList();
		i = 0;
		for each  biz in business
		{
			i = i + 1;
			bizURL = biz.getJSON("url");
			rating = biz.getJSON("rating");
			rating = "(" + rating + "/5.0)";
			name = biz.getJSON("name");
			id = biz.getJSON("id");
			if(name.contains("&"))
			{
				name = replaceAll(name,"&","and");
			}
			if(name.contains("'"))
			{
				name = name.remove("'");
			}
			finalResponse = finalResponse + i + ". " + name + " " + rating + " " + "[See Details](invoke.function|INSERT_YOUR_FUNCTION_NAME|INSERT_YOUR_EMAIL_ID|" + id + ")\n";
		}
	}
}
message.put("text",finalResponse);
return message;


response = Map();
id = arguments.get("key");
resp = invokeurl
[
	url :"https://api.yelp.com/v3/businesses/" + id
	type :GET
	parameters:{"locale":"en_US"}
	connection:"INSERT_CONNECTION_NAME"
];
location = resp.getJSON("location").getJSON("display_address").toJSONList();
address = "";
for each  add in location
{
	address = address + ", " + add.toString();
}
address = address.removeFirstOccurence(",");
name = resp.getJSON("name");
image_url = resp.getJSON("image_url");
rating = resp.getJSON("rating") + "/5.0";
phone = resp.getJSON("display_phone");
url = resp.getJSON("url");
catStr = "";
categories = resp.getJSON("categories").toJSONList();
for each  cat in categories
{
	catStr = cat.get("title") + ", " + catStr;
}
catStr = catStr.removeLastOccurence(",");
addressPlus = address.replaceAll(" ","+");
newAddress = "[" + address + "](https://www.google.com/maps/place/" + addressPlus + ")";
response = {"text":newAddress,"card":{"title":name,"thumbnail":image_url,"theme":"modern-inline"},"slides":{{"type":"label","title":"Information","buttons":{{"label":"More Info","action":{"type":"open.url","data":{"web":url}},"type":"+"}},"data":{{"Phone":phone},{"Rating":rating},{"Categories":catStr}}}}};
//response.put("text",result);
return response;

message = Map();
if(selections.length() > 0)
{
	message.put("text","https://www.youtube.com/watch?v=" + selections.get(0).get("id"));
	info selections;
}
else
{
	message.put("text","Select a video to play!");
}
return message;

if(arguments.contains(" "))
{
	arguments = arguments.replaceAll(" ","+");
}
resp = invokeurl
[
	url :"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&type=video&q=" + arguments
	type :GET
	connection:"Insert_your_connection_name"
	useraccess:true
];
vidlist = resp.get("items");
list = List();
for each  item in vidlist
{
	entry = Map();
	id = item.get("id").get("videoId");
	title = item.get("snippet").get("title");
	desc = item.get("snippet").get("description");
	image = item.get("snippet").get("thumbnails").get("high").get("url");
	entry.put("title",title);
	entry.put("description","");
	entry.put("imageurl",image);
	entry.put("id",id);
	list.add(entry);
}
return list;


message = Map();
headersMp = Map();
headersMp.put("Content-Type","application/json");
//sathisht%40zohocorp.com
searchTicketRspnse = invokeurl
[
	url :"https://zendesk.com/api/v2/search.json?query=type%3Aticket+assignee%3A" + zoho.loginuserid + "+status%3Aopen&sort_by=created_at&sort_order=desc"
	type :GET
	headers:headersMp
	connection:"*INSERT_YOUR_CONNECTION_NAME*"
	useraccess:true
];
info searchTicketRspnse;
count = searchTicketRspnse.getJSON("count");
if(count != "0")
{
	results = searchTicketRspnse.getJSON("results");
	//info results;
	cnt = 1;
	bln = false;
	rspnse = Map();
	rows = "";
	rows = "*Tickets count :* " + count.toLong() + "\n\n";
	for each  result in results
	{
		subjectNme = result.getJSON("subject");
		status = result.getJSON("status");
		desc = result.getJSON("description");
		ticketId = result.getJSON("id");
		requesterId = result.getJSON("requester_id");
		reqstrRspnse = invokeurl
		[
			url :"https://zendesk.com/api/v2/users/" + requesterId + ".json"
			type :GET
			headers:headersMp
			connection:"*INSERT_YOUR_CONNECTION_NAME*"
			useraccess:true
		];
		//info reqstrRspnse;
		emailId = reqstrRspnse.getJSON("user").getJSON("email");
		reqName = reqstrRspnse.getJSON("user").getJSON("name");
		link = "[#" + ticketId + " " + subjectNme + "](*INSERT_YOUR_ZENDESK_SUBDOMAIN*" + ticketId + ")";
		//info cnt+"."+link;
		if(cnt < 6)
		{
			rows = rows + link + "\n";
		}
		else
		{
			bln = true;
			break;
		}
		cnt = cnt + 1;
	}
	info rows;
	message.put("text",rows);
	if(bln)
	{
		buttonAry = List();
		buttonObj = Map();
		buttonObj.put("label","More");
		buttonObj.put("hint","");
		buttonObj.put("type","+");
		clickObj = Map();
		clickObj.put("type","open.url");
		actionDataObj = Map();
		actionDataObj.put("web","*INSERT_YOUR_ZENDESK_SUBDOMAIN*");
		clickObj.put("data",actionDataObj);
		buttonObj.put("action",clickObj);
		buttonArray = List();
		buttonArray.add(buttonObj);
		message.put("buttons",buttonArray);
	}
}
else
{
	message.put("text","There is no open ticket.");
}
return message;


message = Map();
headersMp = Map();
headersMp.put("Content-Type","application/json");
searchTicketRspnse = invokeurl
[
	url :"https://zendesk.com/api/v2/search.json?query=type%3Aticket+status%3Aopen&sort_by=created_at&sort_order=desc"
	type :GET
	headers:headersMp
	connection:"*INSERT_YOUR_CONNECTION_NAME*"
	useraccess:true
];
//info searchTicketRspnse;
count = searchTicketRspnse.getJSON("count");
if(count != "0")
{
	results = searchTicketRspnse.getJSON("results");
	//info results;
	cnt = 1;
	bln = false;
	rspnse = Map();
	rows = "";
	rows = "*Tickets count :* " + count.toLong() + "\n\n";
	for each  result in results
	{
		subjectNme = result.getJSON("subject");
		status = result.getJSON("status");
		desc = result.getJSON("description");
		ticketId = result.getJSON("id");
		requesterId = result.getJSON("requester_id");
		reqstrRspnse = invokeurl
		[
			url :"https://zendesk.com/api/v2/users/" + requesterId + ".json"
			type :GET
			headers:headersMp
			connection:"*INSERT_YOUR_CONNECTION_NAME*"
			useraccess:true
		];
		//info reqstrRspnse;
		emailId = reqstrRspnse.getJSON("user").getJSON("email");
		reqName = reqstrRspnse.getJSON("user").getJSON("name");
		link = "[#" + ticketId + " " + subjectNme + "](*INSERT_YOUR_ZENDESK_SUBDOMAIN_URL*/" + ticketId + ")";
		//info cnt+"."+link;
		if(cnt < 6)
		{
			rows = rows + link + "\n";
		}
		else
		{
			bln = true;
			break;
		}
		cnt = cnt + 1;
	}
	info rows;
	message.put("text",rows);
	if(bln)
	{
		buttonAry = List();
		buttonObj = Map();
		buttonObj.put("label","More");
		buttonObj.put("hint","");
		buttonObj.put("type","+");
		clickObj = Map();
		clickObj.put("type","open.url");
		actionDataObj = Map();
		actionDataObj.put("web","*INSERT_YOUR_ZENDESK_SUBDOMAIN_URL*");
		clickObj.put("data",actionDataObj);
		buttonObj.put("action",clickObj);
		buttonArray = List();
		buttonArray.add(buttonObj);
		message.put("buttons",buttonArray);
	}
}
else
{
	message.put("text","There is no open ticket.");
}
return message;

message = Map();
headersMp = Map();
headersMp.put("Content-Type","application/json");
searchTicketRspnse = invokeurl
[
	url :"https://zendesk.com/api/v2/search.json?query=type%3Aticket+status%3Apending&sort_by=created_at&sort_order=desc"
	type :GET
	headers:headersMp
	connection:"*INSERT_YOUR_CONNECTION_NAME*"
	useraccess:true
];
info searchTicketRspnse;
count = searchTicketRspnse.getJSON("count");
if(count != "0")
{
	results = searchTicketRspnse.getJSON("results");
	//info results;
	cnt = 1;
	bln = false;
	rspnse = Map();
	rows = "";
	rows = "*Tickets count :* " + count.toLong() + "\n\n";
	for each  result in results
	{
		subjectNme = result.getJSON("subject");
		status = result.getJSON("status");
		desc = result.getJSON("description");
		ticketId = result.getJSON("id");
		requesterId = result.getJSON("requester_id");
		reqstrRspnse = invokeurl
		[
			url :"https://zendesk.com/api/v2/users/" + requesterId + ".json"
			type :GET
			headers:headersMp
			connection:"*INSERT_YOUR_CONNECTION_NAME*"
			useraccess:true
		];
		info reqstrRspnse;
		emailId = reqstrRspnse.getJSON("user").getJSON("email");
		reqName = reqstrRspnse.getJSON("user").getJSON("name");
		link = "[#" + ticketId + " " + subjectNme + "](*INSERT_YOUR_ZENDESK_SUBDOMAIN_URL*/" + ticketId + ")";
		//info cnt+"."+link;
		if(cnt < 6)
		{
			rows = rows + link + "\n";
		}
		else
		{
			bln = true;
			break;
		}
		cnt = cnt + 1;
	}
	info rows;
	message.put("text",rows);
	if(bln)
	{
		buttonAry = List();
		buttonObj = Map();
		buttonObj.put("label","More");
		buttonObj.put("hint","");
		buttonObj.put("type","+");
		clickObj = Map();
		clickObj.put("type","open.url");
		actionDataObj = Map();
		actionDataObj.put("web","*INSERT_YOUR_ZENDESK_SUBDOMAIN_URL*");
		clickObj.put("data",actionDataObj);
		buttonObj.put("action",clickObj);
		buttonArray = List();
		buttonArray.add(buttonObj);
		message.put("buttons",buttonArray);
	}
}
else
{
	message.put("text","There is no open ticket.");
}
return message;


""";