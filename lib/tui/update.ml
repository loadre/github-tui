open Tea.Key

let move_fs move_fn (code_tab : Model.code_tab) =
  let fs = move_fn code_tab.fs in
  { code_tab with fs }

let move_up (model : Model.t) =
  match model.current_tab with
  | Code -> { model with code_tab = move_fs Fs.go_up model.code_tab }
  | Issues -> { model with issues_tab = Model.Issue.move (-1) model.issues_tab }
  | PullRequests -> model

let move_down (model : Model.t) =
  match model.current_tab with
  | Code -> { model with code_tab = move_fs Fs.go_down model.code_tab }
  | Issues -> { model with issues_tab = Model.Issue.move 1 model.issues_tab }
  | PullRequests -> model

let move_back (model : Model.t) =
  match model.current_tab with
  | Code -> { model with code_tab = move_fs Fs.go_back model.code_tab }
  | Issues | PullRequests -> model

let move_next (model : Model.t) =
  match model.current_tab with
  | Code -> { model with code_tab = move_fs Fs.go_next model.code_tab }
  | Issues | PullRequests -> model

let filter (filter : Model.Issue.filter) (model : Model.t) =
  match model.current_tab with
  | Code -> model
  | Issues ->
      {
        model with
        issues_tab = Model.Issue.apply_filter filter model.issues_tab;
      }
  | PullRequests -> model

let update event (model : Model.t) =
  match event with
  (* if we press `q` or the escape key, we exit *)
  | Key "q" | Escape -> `Quit
  (* if we press a digit, we switch to the corresponding tab *)
  | Key "1" -> `Render { model with current_tab = Model.Code }
  | Key "2" -> `Render { model with current_tab = Model.Issues }
  | Key "3" -> `Render { model with current_tab = Model.PullRequests }
  (* directions/movements *)
  | Up | Key "k" -> `Render (move_up model)
  | Down | Key "j" -> `Render (move_down model)
  | Left | Key "h" -> `Render (move_back model)
  | Right | Key "l" -> `Render (move_next model)
  (* Issue/PR selection*)
  | Key "o" -> `Render (filter Model.Issue.filter_open model)
  | Key "c" -> `Render (filter Model.Issue.filter_closed model)
  | Key "a" -> `Render (filter Model.Issue.filter_all model)
  (* otherwise, we do nothing *)
  | _ -> `Render model
