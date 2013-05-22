angular.module('treeBuilder', []).directive('tree', ['$document', ($document) -> { 
  restrict: 'C'
  template: '<ul><li id="{{node.id}}" ng-repeat="node in nodes" ng-include="nodeTpl"></li></ul>' + 
    '<button class="btn btn-small btn-primary" ng-click="add()"> + </button>'
  scope: 
    nodes:       '=ngModel'
    childs:      '@ngChilds'
    addNode:     '&'
    updateNode:  '&'
    deleteNode:  '&'
    moveNode:    '&'
    isRemovable: '&'
    nodeForm:    '@' 
    nodeText:    '@'
    nodeTpl:     '@'
         
  controller: ($scope, $attrs) ->
          
      $scope.add = (node) ->
        $scope.addNode({node: node})

      $scope.edit = (node) ->
        node.editing = true

      $scope.update = (node) ->
        $scope.updateNode({node: node})

      $scope.removeNode = (node) -> 
        $scope.deleteNode({node:node, branch: null})


      $scope.removable = (node) ->
        $scope.isRemovable({node:node})

      $scope.moveNodeTo = (node_id, left_id, right_id) -> 
        $scope.moveNode({node_id:node_id, left_id:left_id, right_id:right_id})



  link: (scope, elm, attrs) -> 

    scope.cancelEdit = (node) ->
      node.editing = false

    scope.formTemplate = (node) -> 
      node.editing = false if !node.editing? 
      if node.editing
        scope.nodeForm
      else
        scope.nodeText

    scope.toggleOpened = (node) ->
      node.opened = !node.opened
      return false

    moveNode = (moved_node, lnode, rnode) ->
      scope.moveNodeTo(moved_node.attr('id'), lnode.attr('id'), rnode.attr('id'))
      true


    $document.ready( () -> 
      $( "#tree" ).sortable({
        items: "li", axis: "y", zIndex: 2000, distance: 10, dropOnEmpty: true, handle: 'div.move-handle',
        update:(event, ui) -> 
          moved_node = $(ui.item);
          left_node = moved_node.prev('li');
          right_node = moved_node.next('li');
          moveNode(moved_node, left_node, right_node);
      });
    )

    true

  }
])
