require 'rails_helper'

RSpec.describe GroupHierarchy, type: :model do
  it "should generate a tree of hashes with group information" do
    root = create_hierarchy_of_groups
    root.reload

    expected = {
      name: 'A',
      url: '/groups/a',
      children: [
        {
          name: 'B',
          url: '/groups/b',
          children: [
            {
              name: 'C',
              url: '/groups/c',
              children: []
            }, {
              name: 'D',
              url: '/groups/d',
              children: []
            }
          ]
        }, {
          name: 'E',
          url: '/groups/e',
          children: []
        }
      ]
    }

    generated = GroupHierarchy.new(root).to_hash

    expect(generated).to eql(expected)
  end

  context 'Generating a group_id list' do
    let(:root) { create_hierarchy_of_groups }
    subject { GroupHierarchy.new(root).to_group_id_list }

    it 'sould have five elements' do
      expect(subject.length).to eql(5)
    end

    it 'should include each of the five groups' do
      %w[ A B C D E ].each do |name|
        expect(subject).to include(Group.find_by_name(name).id)
      end
    end
  end
end

def create_hierarchy_of_groups
  create(:group, name: 'A', slug: 'a', children: [
    create(:group, name: 'B', slug: 'b', children: [
      create(:group, name: 'C', slug: 'c', children: []),
      create(:group, name: 'D', slug: 'd', children: [])
    ]),
    create(:group, name: 'E', slug: 'e', children: [])
  ])
end