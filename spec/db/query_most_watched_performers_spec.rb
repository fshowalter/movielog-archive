# frozen_string_literal: true
require 'spec_helper'

describe Movielog::Db::QueryMostWatchedPerformers do
  let(:db) do
    titles = {
      'Rio Bravo (1959)' => {
        title: 'Rio Bravo (1959)',
        display_title: 'Rio Bravo (1959)',
        year: '1959',
        sortable_title: 'Rio Bravo (1959)',
        aka_titles: ["Howard Hawks' Rio Bravo"],
      },
      'Fright Night (1985)' => {
        title: 'Fright Night (1985)',
        display_title: 'Fright Night (1985)',
        year: '1985',
        sortable_title: 'Fright Night (1985)',
        aka_titles: [],
      },
      "Child's Play (1988)" => {
        title: "Child's Play (1988)",
        display_title: "Child's Play (1988)",
        year: '1988',
        sortable_title: "Child's Play (1988)",
        aka_titles: [],
      },
      'Thinner (1996)' => {
        title: 'Thinner (1996)',
        display_title: 'Thinner (1996)',
        year: '1996',
        sortable_title: 'Thinner (1996)',
        aka_titles: [],
      },
    }

    viewings = [
      OpenStruct.new(db_title: 'Rio Bravo (1959)', date: Date.parse('2011-03-12')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2012-03-12')),
      OpenStruct.new(db_title: "Child's Play (1988)", date: Date.parse('2012-03-12')),
      OpenStruct.new(db_title: 'Thinner (1996)', date: Date.parse('2013-03-12')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2013-03-12')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2014-03-12')),
      OpenStruct.new(db_title: "Child's Play (1988)", date: Date.parse('2015-02-22')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2015-03-12')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2016-03-12')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2016-04-14')),
      OpenStruct.new(db_title: "Child's Play (1988)", date: Date.parse('2016-05-22')),
      OpenStruct.new(db_title: 'Fright Night (1985)', date: Date.parse('2016-06-12')),
    ]

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
            position_in_credits: '4' },
        ],
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
            position_in_credits: '2' },
        ],
      },
      'Sarandon, Chris' => {
        full_name: 'Sarandon, Chris',
        last_name: 'Sarandon',
        first_name: 'Chris',
        annotation: nil,
        performer_credits: [
          { title: 'Fright Night (1985)',
            notes: nil,
            role: 'Jerry Dandrige',
            position_in_credits: '1' },
          { title: "Child's Play (1988)",
            notes: nil,
            role: 'Mike Norris',
            position_in_credits: '1' },
        ],
      },
    }

    db = stub_movie_db(titles: titles, cast_and_crew: cast_and_crew)
    Movielog::Db::UpdateMostWatchedTables.call(db: db, viewings: viewings)
    db
  end

  it 'creates the most watched tables and populates the viewing list' do
    persons = Movielog::Db::QueryMostWatchedPerformers.call(db: db)

    expect(persons.length).to eq(1)
    expect(persons.first.full_name).to eq('Sarandon, Chris')
  end
end
