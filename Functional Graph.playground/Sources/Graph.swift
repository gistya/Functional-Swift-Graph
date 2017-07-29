import Foundation

public typealias Id = Int

public enum Direction:Equatable {
    case to
    case from
    case left
    case right
    case none
}

public struct Graph<_Content:Hashable> {
    public typealias _Node = Node<_Content>
    public typealias _Nodes = [_Node]
    public typealias _Edge = Edge<_Content>
    public typealias _Edges = [_Edge]
    public typealias _AdjacencyList = [_Edges]
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
        newAdjacencyList.append([])
        
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
            newAdjacencyList.append([])
            
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
        //let removedAdjacents = adjacencyList[nodeToRemove.id]
        newAdjacencyList.remove(at: nodeToRemove.id)
        
        newNodes.remove(at: nodeToRemove.id)
        _ = newNodes.filter({ $0.id > nodeToRemove.id })
            .map({node -> _Node in 
                var updatedNode = node
                updatedNode.id -= 1
                return updatedNode
            })
                
        // Build a new graph from the new nodes and old adjacency list.
        var graph = Graph(isDirected:isDirected)
        for node in newNodes {
            graph = graph.add(nodeWith: node.value)
        }
        _ = newAdjacencyList.map { edges in
            edges
                .filter({ edge in 
                    if nil == edge.directory.index(forKey: nodeToRemove.id) {
                        return true
                    }
                    return false
                })
                .map({ edge in
                    let nodeId = edge.directory.filter({ (id,direction) in
                        let dir = isDirected ? Direction.from : Direction.left
                        return direction == dir
                    })[0].key
                    var newNodeId = nodeId
                    newNodeId > nodeToRemove.id ? newNodeId -= 1 :()
                    var otherNodeId = edge.other(nodeId:nodeId)
                    otherNodeId > nodeToRemove.id ? otherNodeId -= 1 :()
                    graph = graph.connect(node: graph.nodes[newNodeId], to: graph.nodes[otherNodeId])
                })
        }
        return graph
    }
}

/// Edges Addition
extension Graph {
    
    /// Connect two nodes in the graph to each other
    /// Returns nil if the nodes weren't in the graph to begin with.
    public func connect(node node1:_Node, to node2:_Node) /* throws */ -> _Graph {
        if self.nodes.contains(node1) == false || self.nodes.contains(node2) == false {
            print("ERROR .. attempt to connect nodes not in graph")
            //TODO: throw error
            return self
        }
        
        // Don't add an edge if there's already one.
        let edges:_Edges = adjacencyList[node1.id]
        if edges.contains(where: { existingEdge in
            if existingEdge.directory.keys.contains(node1.id) && existingEdge.directory.keys.contains(node2.id) {
                return true
            }
            return false
        }) {
            return self
        }
        
        let edge = _Edge(from: node1, to: node2, isDirected: isDirected)
        
        // Add edge to adjacency list of graph
        var newAdjacencyList = adjacencyList
        newAdjacencyList[node1.id].append(edge) 
        
        if isDirected == false { newAdjacencyList[node2.id].append(edge) } 
        
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
    public func edges(adjacentTo node:_Node)->_Edges? {
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
    public func edges(adjacentTo nodeId:Id)->_Edges? {
        if(nodeCount <= nodeId) {
            return nil
        }
        return adjacencyList[nodeId]
    }
    
    /// Returns nil if content is not in graph.
    /// Otherwise returns a dictionary keyed by nodeId
    /// and valued with edges emanating from nodes that have the content. 
    public func edges(adjacentToNodesWith content:_Content)->[Id:_Edges] {
        guard let matchingNodeIds = lookup[content] else {
            return [:]
        }
        var results = [Id:_Edges]()
        for nodeId in matchingNodeIds {
            results[nodeId] = self.edges(adjacentTo: nodeId)
        }
        return results
    }
}

/// Search
extension Graph { 
    
    /// Uses Breadth First Search to flatten the graph. 
    /// Returned graph will be a linked list in the order things were searched.
    public func bfsFlatMap(source: _Node, query: _Node? = nil)->_Graph {
        var q = [_Node?]()
        q.append(source)
        var graph = _Graph()
        graph = graph.upsert(node: source)
        
        while let node = q.removeLast() {
            if let edges = edges(adjacentTo: node) {
                for edge in edges {
                    let neighbor = nodes[edge.other(nodeId: node.id)]
                    if !graph.nodes.contains(neighbor) {
                        q.insert(neighbor, at: 0)
                        graph = graph.upsert(node: neighbor)
                        graph = graph.connect(node:graph.nodes[graph.nodeCount - 2], to:graph.nodes[graph.nodeCount - 1])
                        if neighbor == query {
                            return graph
                        }
                    }
                }
            } 
            // necessary because q.removeLast() errors if q is empty :/
            if q.count == 0 {
                break
            }
        }
        return graph
    }
    
    /// Uses Depth First Search to flatten the graph. 
    /// Returned graph will be a linked list in the order things were searched.
    public func dfsFlatMap(source: _Node, query: _Node? = nil)->_Graph {
        var s = [_Node?]()
        s.append(source)
        var graph = _Graph()
        
        var firstRun = true
        while let node = s.removeFirst() {
            if !graph.nodes.contains(node) {
                graph = graph.upsert(node: node)
                if(firstRun == false) {
                    graph = graph.connect(node:graph.nodes[graph.nodeCount - 2], to:graph.nodes[graph.nodeCount - 1])
                }
                firstRun = false
                if node == query {
                    return graph
                }
                _ = edges(adjacentTo: node).map({ edges in
                    edges.reversed().map({ edge in
                        let neighbor = nodes[edge.other(nodeId: node.id)]
                        s.insert(neighbor, at: 0)
                    })
                })
            }
            // necessary because q.removeLast() errors if q is empty :/
            if s.count == 0 {
                break
            }
        }
        return graph
    }
}


