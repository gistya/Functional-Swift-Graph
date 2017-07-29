import Foundation

public typealias Id = Int

public enum Direction:Equatable {
    case to
    case from
    case none
}

public struct Graph<_Content:Hashable> {
    public typealias _Node = Node<_Content>
    public typealias _Nodes = [_Node]
    public typealias _Edge = Edge<_Content>
    public typealias _Edges = [_Edge]
    public typealias _Adjacents = [Id:_Edge]
    public typealias _AdjacencyList = [_Adjacents]
    public typealias _Lookup = [_Content:[Id]]
    public typealias _Graph = Graph<_Content>
    public typealias _Direction = Direction
    
    public let nodes:_Nodes
    public let adjacencyList:_AdjacencyList
    public let lookup:_Lookup
    public let isDirected:Bool
    
    public init(nodes:_Nodes = _Nodes(), adjacencyList:_AdjacencyList = _AdjacencyList(), lookup:_Lookup = _Lookup(), isDirected:Bool = false) {
        self.nodes = nodes
        self.adjacencyList = adjacencyList
        self.isDirected = isDirected
        self.lookup = lookup
    }
    public var nodeCount:Id {
        get {
            return nodes.count
        }
    }
}

/// Node Addition & Removal
extension Graph {
    
    /// Add a node
    public func add(nodeWith content:_Content)->_Graph {
        var newAdjacencyList = adjacencyList
        newAdjacencyList.append([:])
        
        let newNode = _Node(id:nodeCount, value:content)
        
        var newNodes = nodes
        newNodes.append(newNode)
        
        var newNodeLookup = self.lookup
        if var lookup = newNodeLookup[content] {
            lookup.append(newNode.id)
            newNodeLookup[content] = lookup
        } else {
            newNodeLookup[content] = [newNode.id]
        }
        return Graph(nodes: newNodes, adjacencyList: newAdjacencyList, lookup: newNodeLookup, isDirected: isDirected)
    }
    
    public func upsert(node:_Node)->Graph {
        if nodes.contains(node) {
            print("ERROR! Graph already contains node. Returning...")
            return self 
        } else {
            var newAdjacencyList = adjacencyList
            newAdjacencyList.append([:])
            
            var newNodes = nodes
            var newNode = node
            newNode.id = nodeCount
            newNodes.append(newNode)
            
            let content = newNode.value
            
            var newNodeLookup = self.lookup
            if var lookup = newNodeLookup[content] {
                lookup.append(newNode.id)
                newNodeLookup[content] = lookup
            } else {
                newNodeLookup[content] = [newNode.id]
            }
            //print("\n new adjacency list: ",newAdjacencyList)
            return Graph(nodes: newNodes, adjacencyList: newAdjacencyList, lookup: newNodeLookup, isDirected: isDirected)
        }
    }
    
    /// Remove a node
    public func remove(node nodeToRemove:_Node) /* throws */ ->_Graph {
        var newNodes = nodes
        var newAdjacencyList = adjacencyList
        let removedAdjacents = adjacencyList[nodeToRemove.id]
        newAdjacencyList.remove(at: nodeToRemove.id)
        
        newNodes.remove(at: nodeToRemove.id)
        _ = newNodes.filter({ $0.id > nodeToRemove.id })
            .map({node -> _Node in 
                var updatedNode = node
                updatedNode.id -= 1
                return updatedNode
            })
        
        // Get any incoming edges we need to remove, and remove them.
        guard let edgesToRemove = edges(adjacentTo: nodeToRemove.id) else {
            // If no edges were adjacent then just return self.
            // TODO: possibly thrown an error?
            return self
        }
        
        // Iterate through the edges to remove. If they are part of the
        // already removed adjacents, keep going. Otherwise, remove them.
        _ = edgesToRemove.filter({(id,edge) in id != nodeToRemove.id }).filter({ (id,edge) in 
            if let testEdge = removedAdjacents[id] {
                return testEdge.hashValue != edge.hashValue
            } else {
                return true
            }
        }).filter({ (id,edge) in
            edge.directory.keys.contains(nodeToRemove.id) == true
        }).map { (id,edge) in
            edge.directory.filter({ (id,direction) in id != nodeToRemove.id }).map({ (id,direction) in
                let adjustment = id > nodeToRemove.id ? 1 : 0
                let pos = id - adjustment
                
                // Get all the edges for that node.
                var newAdjacents = newAdjacencyList[pos]
                
                // Find the position in that array of the edge to remove. 
                newAdjacents.removeValue(forKey: nodeToRemove.id)
                newAdjacencyList[pos] = newAdjacents
            })
        }
        
        // Build a new graph from the new nodes and old adjacency list.
        var graph = Graph(isDirected:isDirected)
        for node in newNodes {
            graph = graph.add(nodeWith: node.value)
        }
        _ = newAdjacencyList.map { adjacencySet in
            adjacencySet
                .filter({ (id,edge) in id != nodeToRemove.id })
                .map({ (nodeId,edge) in
                    var newNodeId = nodeId
                    newNodeId > nodeToRemove.id ? newNodeId -= 1 :()
                    var otherNodeId = edge.other(nodeId:nodeId)
                    otherNodeId > nodeToRemove.id ? otherNodeId -= 1 :()
                    graph = graph.connect(node1: graph.nodes[newNodeId], to: graph.nodes[otherNodeId])
                })
        }
        return graph
    }
}

/// Edges Addition
extension Graph {
    
    /// Connect two nodes in the graph to each other
    /// Returns nil if the nodes weren't in the graph to begin with.
    public func connect(node1:_Node, to node2:_Node) /* throws */ -> _Graph {
        if self.nodes.contains(node1) == false || self.nodes.contains(node2) == false {
            print("ERROR .. attempt to connect nodes not in graph")
            //TODO: throw error
            return self
        }
        
        let edge = _Edge(from: node1, to: node2, isDirected: isDirected)
        
        // Add edge to adjacency list of graph
        var newAdjacencyList = adjacencyList
        newAdjacencyList[node1.id][node2.id] = edge 
        
        if isDirected == false { newAdjacencyList[node2.id][node1.id] = edge } 
        
        // Return new graph
        let graph = Graph(nodes: nodes, adjacencyList: newAdjacencyList, lookup:lookup, isDirected: isDirected)
        //print("\n**adjacency after connection: \(graph.adjacencyList)\n")
        return graph
    }
}

/// Edges Lookup
extension Graph {
    
    /// Returns nil if node is not in graph. 
    /// Returns [] if there are no adjacent edges. 
    public func edges(adjacentTo node:_Node)->[Id:_Edge]? {
        if(nodeCount <= node.id) {
            return nil
        }
        if(nodes[node.id] == node) {
            return edges(adjacentTo:node.id)
        }
        else {
            return nil
        }
    }
    public func edges(adjacentTo nodeId:Id)->[Id:_Edge]? {
        if(nodeCount <= nodeId) {
            return nil
        }
        return adjacencyList[nodeId]
    }
    
    /// Returns nil if content is not in graph.
    /// Otherwise returns a dictionary keyed by nodeId
    /// and valued with edges emanating from nodes that have the content. 
    public func edges(adjacentToNodesWith content:_Content)->[Id:_Adjacents] {
        guard let matchingNodeIds = lookup[content] else {
            return [:]
        }
        var results = [Id:_Adjacents]()
        for nodeId in matchingNodeIds {
            results[nodeId] = self.edges(adjacentTo: nodeId)
        }
        return results
    }
}

/// Search
extension Graph { 
    public func bfs(source: _Node)->_Graph {
        var q = [_Node?]()
        q.append(source)
        var graph = _Graph()
        graph = graph.upsert(node: source)
        
        while let node = q.removeLast() {
            _ = edges(adjacentTo: node).map({ idEdgeDict in
                idEdgeDict.map({ (id,edge) in
                    let neighbor = nodes[edge.other(nodeId: node.id)]
                    if !graph.nodes.contains(neighbor) {
                        q.append(neighbor)
                        graph = graph.upsert(node: neighbor)
                    }
                })
            })
            // necessary because q.removeLast() errors if q is empty :/
            if q.count == 0 {
                break
            }
        }
        for node in graph.nodes { 
            if graph.nodes.endIndex - node.id < 2 {
                continue
            }
            graph = graph.connect(node1: node, to: graph.nodes[node.id + 1])
        }
        return graph
    }
}


