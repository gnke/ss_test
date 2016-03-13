class Todo::Create < Trailblazer::Operation
  include Model
  model Todo, :create

  contract do
    property :title, validates: { presence: true }
  end

  def process(params)
    validate(params[:todo]) do
      update_todo_list(contract.model, params)
      contract.save
    end
  end

  private

  def update_todo_list(todo, params)
    todo.list = TodoList::Create.(params).model
    todo.list.user = User::Create.(params).model
    todo.list.save
  end
end
