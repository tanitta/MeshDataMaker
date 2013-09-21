f = io.open("input.x", "r")
out = io.open("output.lua","w")
print(f:lines())

for line in f:lines() do
	data = f:read("*a")--stringをdataに代入

	--表示だけ
	--print(line)

end
header, footer = data:find("\nMesh {")
print("header ", header," footer",footer)
print(data:sub(header,footer))

--頂点数取得
header, footer = data:find(" %d+",footer)
points = tonumber(data:sub(header,footer))
print("points = ", points)

--点の座標を格納するテーブル
tabPoint = {}
for i = 0,points-1 do
	tabPoint[i] = {}
end

--頂点座標を格納
for i = 0 ,points-1 do
	--1行あたりの処理
	for j = 1,3 do
		header, footer = data:find("%w+.%w+;",footer)
		local h2,f2 = data:find("-",header-1)
		local sign = 0
		if h2 == header-1 then
			sign = -1
		else
			sign = 1
		end
		tabPoint[i][j] = tonumber(data:sub(header,footer-1))*sign
		print("i = ", i, "j = ",j,tabPoint[i][j])
		--print(sign);
	end
end

--面数を取得
header, footer = data:find(" %d+",footer)
faces = tonumber(data:sub(header,footer))
print("faces = ", faces)

tabFace = {}
for i = 0,faces-1 do
	tabFace[i] = {}
end

for i = 0 ,faces-1 do
	--行頭の数値(角数)を求める
	header, footer = data:find(" %d+",footer)
	n = tonumber(data:sub(header,footer))
	--print(i, "n = ", n)

	--
	--1行あたりの処理
	for j = 1,n-1 do
		header, footer = data:find("%d+,",footer)
		local h2,f2 = data:find("-",header-1)
		local sign = 0
		if h2 == header-1 then
			sign = -1
		else
			sign = 1
		end
		tabFace[i][j] = tonumber(data:sub(header,footer-1))*sign
		print("i = ", i, "j = ",j,tabFace[i][j])
		--print(sign);
	end
	header, footer = data:find("%d+;",footer)
	local h2,f2 = data:find("-",header-1)
	local sign = 0
	if h2 == header-1 then
		sign = -1
	else
		sign = 1
	end
	tabFace[i][n] = tonumber(data:sub(header,footer-1))*sign
	print("i = ", i, "j = ",n,tabFace[i][n])
end


str = [[namespace "landdata"{
	class "hoge"{
		metamethod "_init"
		:body(
			function(self)
				]]
out:write(str)
out:write("self.numPoints = "..points.."\n")
str = [[
				]]
out:write(str)
out:write("self.numFaces = "..faces.."\n")
out:write(str.."self.tabPoint = {}\n")
out:write(str.."self.tabFace = {}\n")
for i = 0, points-1 do
	out:write(str.."self.tabPoint[",i,"] = {",tabPoint[i][1] ,",",tabPoint[i][2], ",",tabPoint[i][3] ,"}\n")
end

for i = 0, faces-1 do
	if table.getn(tabFace[i]) == 3 then
		out:write(str.."self.tabFace[",i,"] = {self.tabPoint[",tabFace[i][1] ,"], self.tabPoint[",tabFace[i][2], "], self.tabPoint[",tabFace[i][3] ,"] }\n")
	elseif  table.getn(tabFace[i]) == 4  then
		out:write(str.."self.tabFace[",i,"] = {self.tabPoint[",tabFace[i][1] ,"], self.tabPoint[",tabFace[i][2], "], self.tabPoint[",tabFace[i][3], "], self.tabPoint[",tabFace[i][4] ,"] }\n")
	end
end

str =[[			end

		);

		method "GetFace"
		:body(
			function(self,idx)
				return self.tabFace[idx]
			end
		);
	};
};]]
out:write(str)

print(os.clock ())
--[[
for line in f:lines() do
	out:write(line.."\n")

	--表示だけ
	--print(line)

end]]
out:close()
f:close()
