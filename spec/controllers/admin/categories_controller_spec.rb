# frozen_string_literal: true

require 'rails_helper'

# There's no way to test the drag-and-drop through the system specs, so...
RSpec.describe Admin::CategoriesController, type: :controller do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before :each do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all
    create_list(:category, 2, :with_subcategories_concepts_and_data_elements)
  end

  context 'sort' do
    it 'Moves a subcategory from one root category to another' do
      root1, root2 = Category.roots

      sign_in admin_user
      post :sort, params: {
        tree_nodes: {
          0 => {
            id: root1.id,
            children: {
              0 => { id: root1.children.first.id },
              1 => { id: root2.children.first.id }
            }
          },
          1 => {
            id: root2.id
          }
        }
      }

      expect(response).to be_successful
      expect(root1.reload.children.count).to eq(2)
      expect(root2.reload.children.count).to eq(0)
    end

    it 'Moves a subcategory to root category' do
      root1, root2 = Category.roots

      sign_in admin_user
      post :sort, params: {
        tree_nodes: {
          0 => { id: root2.children.first.id },
          1 => {
            id: root1.id,
            children: {
              0 => { id: root1.children.first.id }
            }
          },
          2 => {
            id: root2.id
          }
        }
      }

      expect(response).to be_successful
      expect(root1.reload.children.count).to eq(1)
      expect(root2.reload.children.count).to eq(0)
      expect(Category.roots.count).to eq(3)
    end

    it 'Moves a root category to a subcategory' do
      root1, root2 = Category.roots

      sign_in admin_user
      post :sort, params: {
        tree_nodes: {
          0 => {
            id: root1.id,
            children: {
              0 => { id: root1.children.first.id },
              1 => {
                id: root2.id,
                children: {
                  0 => { id: root2.children.first.id }
                }
              }
            }
          }
        }
      }

      expect(response).to be_successful
      expect(root1.reload.children.count).to eq(2)
      expect(root2.reload.children.count).to eq(1)
      expect(Category.roots.count).to eq(1)
      expect(root2.root).to eq(root1)
    end
  end
end
