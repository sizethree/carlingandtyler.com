ct.directive 'cViewBuffer', ['$rootScope', '$route', '$compile', '$controller', ($rootScope, $route, $compile, $controller) ->
  
  exists = angular.isDefined
  current_element = null
  current_scope = null
  available_buffers = []
  active_index = 0

  cleanup = () ->
    if current_scope
      current_scope.$destroy()
      current_scope = null

  update = () ->
    active_buffer = available_buffers[active_index]
    if active_buffer
      swap()

  swap = () ->
    active_buffer = available_buffers[active_index]
    current = $route.current
    locals = if current then current.locals else false
    template = if locals then locals.$template else false
    $element = active_buffer.element
    $scope = active_buffer.scope
    $scope.active = true

    if template != false and exists template
      cleanup()
      new_scope = $scope.$new()

      $element.html template
      link_fn = $compile $element.contents()

      locals.$scope = new_scope

      if current.controller
        new_controller = $controller current.controller, locals
        $element.data '$ngControllerController', new_controller
        $element.children().data '$ngControllerController', new_controller

      new_element = link_fn new_scope
      current_scope = new_scope

  class ViewBuffer

    constructor: (@scope, @element) ->

  ViewBuffer.$inject = ['$scope', '$element']

  cViewBuffer =
    replace: true
    templateUrl: 'directives.view_buffer'
    transclude: 'element'
    controller: ViewBuffer
    link: ($scope, $element, $attrs, $controller, $transclude) ->
      $scope.active = false
      available_buffers.push $controller

  $rootScope.$on '$routeChangeSuccess', update

  cViewBuffer
]