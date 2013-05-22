//= require 'angular'
//= require 'angular-resource'
//= require 'angular-tree'

app = angular.module('treeApp',["ngResource","treeBuilder"])
.config(['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.headers.post['Content-Type'] = 'application/json'
  $httpProvider.defaults.headers.put['Content-Type'] = 'application/json'
  # assumes the presence of jQuery
  token = $("meta[name='csrf-token']").attr("content")
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = token
  $httpProvider.defaults.headers.put['X-CSRF-Token'] = token
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

])
.factory("Node", ["$resource", ($resource) -> 
  window.node_path ?= '/nodes/:id/:action'
  $resource(window.node_path, {id: "@id"}, 
    { 
      update: { method: 'PUT' }, 
      move: { method:'PUT', params: { left:"@lft", right:"@rgt", action: 'move' } }
    }
  )
])
.controller("TreeCtrl", ['$scope', 'Node', ($scope, Node) ->

  $scope.nodes = Node.query( () ->
      $scope.nodes_by_parent = {}
      angular.forEach($scope.nodes, (node, idx) -> 
        pid = node.parent_id || 0
        $scope.nodes_by_parent[pid] = [] if !$scope.nodes_by_parent[pid]
        $scope.nodes_by_parent[pid].push(idx)
      )
      tree = []
      addChilds(tree, 0)
      $scope.nodes = tree
  )
  
  addChilds = (branch, parent_id) ->
    if $scope.nodes_by_parent[parent_id]
      angular.forEach($scope.nodes_by_parent[parent_id], (node_idx, idx) -> 
        node = $scope.nodes[node_idx]
        branch.push(node)
        node.nodes = [] if !node.nodes
        addChilds(node.nodes, node.id)
      )

  $scope.addNode = (node) ->
    if node
      node.nodes = [] if !node.nodes
      node.nodes.push new Node({name: 'child', editing:true, parent_id: node.id })
    else
      $scope.nodes.push new Node({name: 'next root', editing:true })

  $scope.update = (node) ->
    node.editing = false
    if node.id
      node.$update()
    else
      node.$save()

  $scope.canRemove = (node) -> $scope.nodes.length > 1 && !node.undeleteable

  $scope.deleteNode = (node, branch = $scope.nodes) ->
    return false  if !$scope.canRemove(node)
    branch = $scope.nodes if !branch 
    angular.forEach(branch, (next_node, idx) -> 
      if next_node == node 
        node.$remove()
        this.splice(idx,1)
        return true
      else if (next_node.nodes) 
        $scope.deleteNode(node, next_node.nodes)
    , branch)
  
  $scope.findPlaceOfId = (id, branch = $scope.nodes) ->
    id = id*1
    found = false
    for node, idx in branch
      if node.id == id
        found = [branch, idx] 
        break
      found = $scope.findPlaceOfId(id, node.nodes) if node.nodes && node.nodes.length
      break if found
    found

  $scope.moveNodeToLeftOf = (node_place, right_place)->
    if right_place[0] == node_place[0] && node_place[1] < right_place[1] then right_place[1]--
    right_place[0].splice(right_place[1], 0, (node = node_place[0].splice(node_place[1],1)[0]) )
    node

  $scope.moveNodeToRightOf = (node_place, left_place)->
    if left_place[0] == node_place[0] && node_place[1] < left_place[1] then left_place[1]--
    left_place[0].splice(left_place[1]+1, 0, (node = node_place[0].splice(node_place[1],1)[0]) )
    node

  $scope.moveNodeTo = (node_id, left_id, right_id) ->
    place = $scope.findPlaceOfId(node_id)
    left_place = $scope.findPlaceOfId(left_id) if left_id
    right_place = $scope.findPlaceOfId(right_id) if right_id
    if place && right_place then node = $scope.moveNodeToLeftOf(place, right_place) else node = $scope.moveNodeToRightOf(place, left_place)
    node.rgt = right_id
    node.lft = left_id
    node.$move()
  true

])

