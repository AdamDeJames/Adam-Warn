// SERVERSIDE SQL FILE \\
require("mysqloo")
aw_sql = {}
if(aw_sv.MySQL == true) then
  local db = mysqloo.connect(aw_sv.Host, aw_sv.User, aw_sv.Pass, aw_sv.Db)
  aw_sql.sql = db or nil

  function mysqle(str)
    if(type(str) != "string") then
		  return aw_sql.sql:escape(tostring(str))
    elseif(type(str) == "string") then
		  return aw_sql.sql:escape(str)
    end
  end
 
  function db.onConnected()
    if(aw_sh.Debug == true) then
  		MsgC(Color(255, 0, 0, 255), "[Adam Warn Debug] ", Color(255, 255, 255, 255), "Connection to the database finished!\n")
  	end
  end
 
  function db.onConnectionFailed(err)
    if(aw_sh.Debug == true) then
  		MsgC(Color(255, 0, 0, 255), "[Adam Warn Debug] ", Color(255, 255, 255, 255), "connection to the database failed! Error:\n"..err)
  	end
  end
 
 
  function db:Query(query, callback, test)
    if !query then
      print("Error executing query, no query specified.")
      return
    else
 
      local q = db:query(query)
 
      if !q then return end
      function q:onSuccess(data)
        if callback then callback(data) end
      end
 
      function q:onError(err, qur)
        print("Error executing query, Error: "..err..", Query: "..qur)
        if (!db or db:status() == mysqloo.DATABASE_NOT_CONNECTED) then
          db:connect()
        end
      end
 
      q:start()
      return q:getData()
    end
  end

  db:connect()
else
    if(not sql.TableExists("warns")) then
      sql.Query([[CREATE TABLE `warns` (
  `id`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `name`  varchar(255) NOT NULL,
  `steamid` varchar(255) NOT NULL,
  `time_warned` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reason`  varchar(255) NOT NULL,
  `admin` varchar(255) NOT NULL
);]])
      if(not sql.TableExists("warns")) then
        print(sql.LastError())
      end
    else
      return
    end
end