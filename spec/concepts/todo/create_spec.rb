require "rails_helper"

RSpec.describe Todo::Create do
  context "validations" do
    it "should be invalid if the title is empty" do
      expect { Todo::Create.(todo: { title: "" }) }
        .to raise_error Trailblazer::Operation::InvalidContract
    end
  end

  context "todo list is present" do
    let(:todo_list) { TodoList.new(id: 1, name: "List 1") }

    before(:each) do
      expect(TodoList).to receive(:find).with(todo_list.id).and_return(todo_list)
      @todo = Todo::Create.(todo: { title: "Todo 1" }, todo_list_id: todo_list.id)
    end

    it_behaves_like "a newly created todo" do
      let(:list) { todo_list }
    end
  end

  context "todo list is not present" do
    let(:default_todo_list) { TodoList.new({ id: 2, name: "Default To-do List" }) }

    before(:each) do
      expect(TodoList).to receive(:find_or_create_by)
        .with(name: "Default To-do List")
        .and_return(default_todo_list)
    end

    it "should find or create the default todo list" do
      todo = Todo::Create.(todo: { title: "Todo 1" })
    end

    context "current user is present" do
      let(:user) { User.new({ id: 1, fullname: "User 1" }) }

      before(:each) do
        @todo = Todo::Create.(todo: { title: "Todo 1" }, current_user: user)
      end

      it "should associate the todo list with the user" do
        expect(default_todo_list.user).to eq(user)
      end

      it "should save the updated todo list" do
        expect(default_todo_list.persisted?).to be true
      end

      it_behaves_like "a newly created todo" do
        let(:list) { default_todo_list }
      end
    end

    context "current user is not present" do
      context "current user id is present" do
        let(:existing_user) { User.create({ id: 2, fullname: "User 2" }) }

        before(:each) do
          expect(User).to receive(:find).with(existing_user.id).and_return(existing_user)
          @todo = Todo::Create.(todo: { title: "Todo 1" }, current_user_id: existing_user.id)
        end

        it "should find the user and associate it with the todo list" do
          expect(default_todo_list.user).to eq(existing_user)
        end

        it "should save the updated todo list" do
          expect(default_todo_list.persisted?).to be true
        end

        it_behaves_like "a newly created todo" do
          let(:list) { default_todo_list }
        end
      end

      context "current user id is not present" do
        let(:guest_user) { User.new({ id: 3, fullname: "Guest" }) }

        before(:each) do
          expect(User).to receive(:create!).with(fullname: guest_user.fullname).and_return(guest_user)
          @todo = Todo::Create.(todo: { title: 'Todo 1' })
        end

        it "should create the user and associate it with the todo list" do
          expect(default_todo_list.user).to eq(guest_user)
        end

        it "should save the updated todo list" do
          expect(default_todo_list.persisted?).to be true
        end

        it_behaves_like "a newly created todo" do
          let(:list) { default_todo_list }
        end
      end
    end
  end
end
