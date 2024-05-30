-- ======================================================================
-- Copyright (c) 2012 RapidFire Studio Limited 
-- All Rights Reserved. 
-- http://www.rapidfirestudio.com

-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ======================================================================

module ( "astar", package.seeall )

----------------------------------------------------------------
-- local variables
----------------------------------------------------------------

local INF = 1/0
local cachedPaths = nil

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------

function manhattan_dist ( x1, y1, x2, y2 )
	
	return math.abs(x2 - x1) + math.abs(y2 - y1)
end

function dist_between ( nodeA, nodeB )

	return manhattan_dist ( nodeA.x, nodeA.y, nodeB.x, nodeB.y )
end

function heuristic_cost_estimate ( nodeA, nodeB )

	return manhattan_dist ( nodeA.x, nodeA.y, nodeB.x, nodeB.y )
end

function lowest_f_score ( set, f_score )

	local lowest, bestNode = INF, nil
	for node, _ in pairs(set) do
		local score = f_score[node]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

function neighbor_nodes ( theNode, nodes, goal )
	local neighbors = {
		Cell(theNode.x - 1, theNode.y),
		Cell(theNode.x + 1, theNode.y),
		Cell(theNode.x, theNode.y - 1),
		Cell(theNode.x, theNode.y + 1),
		Cell(theNode.x - 1, theNode.y - 1),
		Cell(theNode.x + 1, theNode.y + 1),
		Cell(theNode.x + 1, theNode.y - 1),
		Cell(theNode.x - 1, theNode.y + 1),
	}
	local i = 1
	while i <= #neighbors do
		-- Goal is always a valid neighbor
		if not (goal == neighbors[i] or nodes:contains(neighbors[i])) then
			neighbors[i] = neighbors[#neighbors]
			neighbors[#neighbors] = nil
		else
			i = i + 1
		end
	end

	return neighbors
end

function unwind_path ( flat_path, map, current_node )

	if map [ current_node ] then
		table.insert ( flat_path, 1, map [ current_node ] ) 
		return unwind_path ( flat_path, map, map [ current_node ] )
	else
		return flat_path
	end
end

----------------------------------------------------------------
-- pathfinding functions
----------------------------------------------------------------

function a_star ( start, goal, nodes )
	local closedset = HashSet()
	local openset = HashSet(start)
	local came_from = HashMap()

	local MAX_IT = 100
	local it = 1

	local g_score, f_score = HashMap(), HashMap()
	g_score [ start ] = 0
	f_score [ start ] = g_score [ start ] + heuristic_cost_estimate ( start, goal )

	while iter_size(openset) > 0 and it < MAX_IT do
		local current = lowest_f_score ( openset, f_score )
		if current == goal then
			local path = unwind_path ( {}, came_from, goal )
			table.insert ( path, goal )
			return path
		end

		openset:remove(current)		
		closedset:add(current)
		
		local neighbors = neighbor_nodes ( current, nodes, goal )
		for _, neighbor in ipairs (neighbors) do
			if not closedset[neighbor] then
			
				local tentative_g_score = g_score [ current ] + dist_between ( current, neighbor )
				 
				if not openset[neighbor] or tentative_g_score < g_score [ neighbor ] then 
					came_from 	[ neighbor ] = current
					g_score 	[ neighbor ] = tentative_g_score
					f_score 	[ neighbor ] = g_score [ neighbor ] + heuristic_cost_estimate ( neighbor, goal )
					if not openset[neighbor] then
						openset:add(neighbor)
					end
				end
			end
		end
		it = it + 1
	end
	return nil -- no valid path
end

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------

function clear_cached_paths ()

	cachedPaths = nil
end

function distance ( x1, y1, x2, y2 )
	
	return dist ( x1, y1, x2, y2 )
end

function path ( start, goal, nodes, ignore_cache )

	if not cachedPaths then cachedPaths = HashMap() end
	if not cachedPaths[start] then
		cachedPaths[start] = HashMap()
	elseif cachedPaths[start][goal] ~= nil and not ignore_cache then
		return cachedPaths[start][goal]
	end

  local resPath = a_star ( start, goal, nodes )
  if cachedPaths[start][goal] == nil and not ignore_cache then
    cachedPaths[start][goal] = resPath
  end

	return resPath
end
