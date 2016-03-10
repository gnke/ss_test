shared_examples_for "a newly created todo" do
  it "should associate the todo with the todo list" do
    expect(@todo.model.list).to eq(list)
  end

  it "should save the newly created todo" do
    expect(@todo.model.persisted?).to be true
  end
end
