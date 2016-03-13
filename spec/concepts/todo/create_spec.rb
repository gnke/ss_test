require "rails_helper"

RSpec.describe Todo::Create do
  context "validations" do
    it "should be invalid if the title is empty" do
      expect { Todo::Create.(todo: { title: "" }) }
        .to raise_error Trailblazer::Operation::InvalidContract
    end
  end

  context "creating a todo" do
    let(:user) { User.new(id: 1, fullname: 'test user') }
    let(:todo_list) { TodoList.new(id: 1, name: "test list") }

    let(:user_create_operation) { double("user operation") }
    let(:todo_list_create_operation) { double("todo list operation") }

    before(:each) do
      params = { todo: { title: "test todo" }, todo_list_id: todo_list.id }

      expect(TodoList::Create).to receive(:call).with(params).and_return(todo_list_create_operation)
      expect(todo_list_create_operation).to receive(:model).and_return(todo_list)
      expect(User::Create).to receive(:call).with(params).and_return(user_create_operation)
      expect(user_create_operation).to receive(:model).and_return(user)

      @todo = Todo::Create.(params)
    end

    it "should associate the todo list with the user" do
      expect(todo_list.user).to eq(user)
    end

    it "should save the updated todo list" do
      expect(todo_list.persisted?).to be true
    end

    it_behaves_like "a newly created todo" do
      let(:todo) { @todo }
      let(:list) { todo_list }
    end
  end
end
