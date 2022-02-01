/* 

--- Polar To Cartesian [cSpd / p2c]
--- Format: p2c(angle_t ang, fixed_t rad, [mobj_t/table m])
--- Returns: fixed_t x, fixed_t y
--- Transforms the given polar coordinates into cartesian cordinates.
--- Optionally takes a table/userdata with a scale parameter to scale the result.
--- Note: No type checks are made, except for "not nil". Make sure all inputs are numbers!


--- Polar To Cartesian 3D [cSpdEx / p2c3d]
--- Format: p2c3d(angle_t hang, angle_t vang, fixed_t rad, [mobj_t/table m])
--- Returns: fixed_t x, fixed_t y
--- Also transforms the given polar coordinates into cartesian cordinates, but in 3D.
--- Optionally takes a table/userdata with a scale parameter to scale the result.
--- Note: No type checks are made, except for "not nil". Make sure all inputs are numbers!


--- collision Z check
--- Format: collZCheck(mobj_t m, mobj_t n)
--- Returns: boolean collide?
--- Returns whether the objects m and n intersect vertically (z position and height).
--- For use in collision hooks, mainly.

--- collision check
--- Format: collCheck(int ms, int ml, int ns, int nl)
--- Basically collZCheck but more universal.
--- Given four values (m start, m length, n start, n length),
--- Returns: boolean whether_they_intersect

--- another one
--- Format: collRadiusCheck(mobj_t m, mobj_t n)
--- collZCheck but horizontal and done twice for each axis.
--- Returns: boolean whether_they_intersect

-- TODO

--- validity check
--- Format: function(mobj_t m, mobj_t n)
--- Returns whether the given object is not nil and is valid.
--- Returns: boolean valid?

--- getDelta
--- Format: function(fixed_t x1, fixed_t y1, fixed_t z1, fixed_t x2, fixed_t y2, fixed_t z2)
--- Returns whether the given object is not nil and is valid.
--- Returns: boolean valid?

cSpd
cSpdEx
collZCheck
collRadiusCheck
collCheck
isValid
getDelta
getPackDelta
vClamp
vWrap
vSplit
vClose
vDist
vSign
vApproach
pointInfo
pointToDist3D
teleTowards
getClosestSolidFlat
findValueInTable
deepcopy
deepcompare
randomChoose
shuffleTable
makeRange
createFlags
createEnum
explodeString

--- title
--- Format: function()
--- Returns:
--- 

*/