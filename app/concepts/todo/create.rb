class Todo::Create < Trailblazer::Operation
  contract do
    property :title, validates: { presence: true }
  end

  def process(params)
    begin
      validate(params[:todo], Todo.new)
    rescue Trailblazer::Operation::InvalidContract
      return invalid!
    end

    todo = @model = Todo.new(params.require(:todo).permit(:title, :description))

    if params[:todo_list_id].present?
      todo_list = TodoList.find(params[:todo_list_id])
      todo.list = todo_list
      todo.save!
      return todo
    end

    todo_list = TodoList.find_or_create_by(name: "Default To-do List")

    current_user = get_or_create_user(params)

    # why? - this can change the ownership of the default todo list
    todo_list.user = current_user
    todo_list.save!

    todo.list = todo_list
    todo.save!
  end

  private

  def get_or_create_user(params)
    return params[:current_user] if params[:current_user].present?

    if params[:current_user_id].nil?
      User.create!(fullname: "Guest")
    else
      User.find(params[:current_user_id])
    end
  end
end
