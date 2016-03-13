class TodoList::Create < Trailblazer::Operation
  def process(params)
    @model =
      if params[:todo_list_id].present?
        TodoList.find(params[:todo_list_id])
      else
        TodoList.find_or_create_by(name: "Default To-do List")
      end
  end
end
