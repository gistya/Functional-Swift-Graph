import Foundation

public struct Edge<_Content:Hashable> {
    public typealias _Node = Node<_Content>
    public typealias _Nodes = [_Node?]
    public typealias _Directory = [Id : Direction]
    public var directory:_Directory 
    public var createdTime = Date()
    public init(directory:_Directory) {
        self.directory = directory
    }
    public init(from node1:_Node, to node2:_Node, isDirected:Bool) {
        var newDirectory:_Directory = _Directory()
        newDirectory[node1.id] = isDirected ? Direction.to   : Direction.none
        newDirectory[node2.id] = isDirected ? Direction.from : Direction.none
        directory = newDirectory
    }
    public static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.createdTime == rhs.createdTime
    }
    public var hashValue: Int {
        get {
            return Int(createdTime.timeIntervalSince1970)
        }
    }
    public func other(nodeId: Id)->Id {
        return directory.filter({ link in
            return link.key != nodeId
        })[0].key
    }
}

extension Edge:CustomStringConvertible {
    public var description:String {
        get {
            var result:String = ""
            for (key, value) in directory {
                result.append("\n     id: \(key), direction: \(value)")
            }
            result.append("\n")
            return result
        }
    }
}
