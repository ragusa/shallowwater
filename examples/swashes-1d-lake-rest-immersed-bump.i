[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 500
  xmin = 0
  xmax = 25
[]

[Functions]
  [./initial_height]
    type = ParsedFunction
    value = '0.5 - (x > 8) * (x < 12) * (0.2 - 0.05 * (x - 10)^2)'
  [../]

  [./b_func]
    type = ParsedFunction
    value = '(x > 8) * (x < 12) * (0.2 - 0.05 * (x - 10)^2)'
  [../]

  [./grad_b_func]
    type = ParsedFunction
    value = '(x > 8) * (x < 12) * (1 - 0.1 * x)'
  [../]
[]

[Variables]
  [./h]
    family = LAGRANGE
    order = FIRST
    [./InitialCondition]
      type = FunctionIC
      function = initial_height
    [../]
  [../]

  [./q]
    family = LAGRANGE
    order = FIRST
    [./InitialCondition]
      type = ConstantIC
      value = 0
    [../]
  [../]
[]

[AuxVariables]
  [./b]
    [./InitialCondition]
      type = FunctionIC
      function = b_func
    [../]
  [../]

  [./grad_b]
    [./InitialCondition]
      type = FunctionIC
      function = grad_b_func
    [../]
  [../]

  [./v]
  [../]

  [./h_plus_b]
  [../]

  [./h_residual]
  [../]

  [./q_residual]
  [../]
[]

[Kernels]
  [./h_time_derivative]
    type = TimeDerivative
    variable = h
  [../]

  [./h_continuity]
    type = SVContinuity
    implicit = false
    variable = h
    q_x = q
  [../]
  
  [./q_time_derivative]
    type = TimeDerivative
    variable = q
  [../]

  [./q_advection]
    type = SVAdvection
    implicit = false
    variable = q
    h = h
    q_x = q
    component = 0
  [../]

  [./q_pressure]
    type = SVPressure
    implicit = false
    variable = q
    h = h
    component = 0
  [../]

  [./q_bathymetry]
    type = SVBathymetry
    implicit = false
    variable = q
    h = h
    b = grad_b
    component = 0
  [../]
[]

[AuxKernels]
  [./v_kernel]
    type = ParsedAux
    variable = v
    function = 'q / h'
    args = 'q h'
  [../]

  [./h_plus_b_kernel]
    type = ParsedAux
    variable = h_plus_b
    function = 'h + b'
    args = 'h b'
  [../]

  [./h_residual_kernel]
    type = DebugResidualAux
    variable = h_residual
    debug_variable = h
  [../]

  [./q_residual_kernel]
    type = DebugResidualAux
    variable = q_residual
    debug_variable = q
  [../]
[]

[Materials]
  [./sv_material]
    type = SVMaterial
    viscosity_type = FIRST_ORDER
    h = h
    q_x = q
  [../]
[]

[BCs]
  [./BC_q_left]
    type = DirichletBC
    variable = q
    boundary = left
    value = 0
  [../]

  [./BC_q_right]
    type = DirichletBC
    variable = q
    boundary = right
    value = 0
  [../]
[]

[Executioner]
  type = Transient

  scheme = explicit-euler
  solve_type = LINEAR

  num_steps = 10
  dt = 1e-6
[]

[Outputs]
  exodus = true
[]
