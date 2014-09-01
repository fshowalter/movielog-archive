require 'spec_helper'
require 'support/stub_template_context'

describe Movielog::Helpers do
  let(:context) { stub_template_context }

  describe '#headline_cast' do
    before(:each) do
      titles = {
        'Rio Bravo (1959)' => {
          title: 'Rio Bravo (1959)',
          display_title: 'Rio Bravo (1959)',
          year: '1959',
          sortable_title: 'Rio Bravo (1959)',
          aka_titles: ["Howard Hawks' Rio Bravo"]
        }
      }

      cast_and_crew = {
        'Dickinson, Angie' => {
          full_name: 'Dickinson, Angie',
          last_name: 'Dickinson',
          first_name: 'Angie',
          annotation: nil,
          performer_credits: [
            { title: 'Rio Bravo (1959)',
              notes: nil,
              role: 'Feathers',
              position_in_credits: '4'
            }]
        },
        'Martin, Dean' => {
          full_name: 'Martin, Dean',
          last_name: 'Martin',
          first_name: 'Dean',
          annotation: nil,
          performer_credits: [
            { title: 'Rio Bravo (1959)',
              notes: nil,
              role: "Dude ('Borachón')",
              position_in_credits: '2'
            }]
        },
        'Wayne, John' => {
          full_name: 'Wayne, John',
          last_name: 'Wayne',
          first_name: 'John',
          annotation: nil,
          performer_credits: [
            { title: 'Rio Bravo (1959)',
              notes: nil,
              role: 'Sheriff John T. Chance',
              position_in_credits: '1'
            }]
        },
        'Nelson, Ricky' => {
          full_name: 'Nelson, Ricky',
          last_name: 'Nelson',
          first_name: 'Ricky',
          annotation: nil,
          performer_credits: [
            { title: 'Rio Bravo (1959)',
              notes: nil,
              role: 'Colorado Ryan',
              position_in_credits: '3'
            }]
        }
      }

      db = stub_movie_db(titles: titles, cast_and_crew: cast_and_crew)
      allow(Movielog).to receive(:db).and_return(db)
    end

    it 'returns a the headline cast for a title as a sentence' do
      expect(context.headline_cast(title: 'Rio Bravo (1959)')).to eq(
        'John Wayne, Dean Martin, and Ricky Nelson')
    end
  end
end
