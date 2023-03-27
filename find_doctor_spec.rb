# frozen_string_literal: true

require 'rspec'
require_relative 'find_doctor'


RSpec.describe FindDoctor do
  describe 'selecting doctors by_day feature' do
    it 'is available through command line' do
      expect(FindDoctor.commands.keys).to include('by_day')
      expect(FindDoctor.commands.keys).not_to include('this_is_not_a_command')
    end
  end

  describe 'when missing input params' do
    describe 'type' do
      it 'returns error with reason' do
        expect do
          FindDoctor
            .new
            .invoke(
              'by_day',
              [],
              path: './doctors.csv',
              day: 'Monday'
            )
        end.to raise_error(
          Thor::RequiredArgumentMissingError,
          "No value provided for required options '--type'"
        )
      end
    end

    describe 'path' do
      it 'returns error with reason' do
        expect do
          FindDoctor
            .new
            .invoke(
              'by_day',
              [],
              type: 'csv',
              day: 'Monday'
            )
        end.to raise_error(
          Thor::RequiredArgumentMissingError,
          "No value provided for required options '--path'"
        )
      end
    end

    describe 'day' do
      it 'returns error with reason' do
        expect do
          FindDoctor
            .new
            .invoke(
              'by_day',
              [],
              type: 'csv',
              path: './doctors.csv'
            )
        end.to raise_error(
          Thor::RequiredArgumentMissingError,
          "No value provided for required options '--day'"
        )
      end
    end
  end
  describe 'when input params are invalid' do
    describe 'type' do
      it 'returns error with reason' do
        expect do
          FindDoctor
            .new
            .invoke(
              'by_day',
              [],
              type: 'json',
              path: './doctors.csv',
              day: '1'
            )
        end.to raise_error(
          Thor::Error,
          "Invalid input value: type"
        )
      end
    end

    describe 'path' do
      it 'returns error with reason' do
        expect do
          FindDoctor
            .new
            .invoke(
              'by_day',
              [],
              type: 'csv',
              path: './test.csv',
              day: '1'
            )
        end.to raise_error(
          Thor::Error,
          "Invalid input value: path"
        )
      end
    end

    describe 'day' do
      it 'returns error with reason' do
        expect do
          FindDoctor
            .new
            .invoke(
              'by_day',
              [],
              type: 'csv',
              path: './doctors.csv',
              day: '11'
            )
        end.to raise_error(
          Thor::Error,
          "Invalid input value: day"
        )
      end
    end

    describe 'are valid' do
      describe 'and day is Monday' do
        it 'returns doctors ON in Monday' do
          expect do
            FindDoctor
              .new
              .invoke(
                'by_day',
                [],
                type: 'csv',
                path: './doctors.csv',
                day: 'Monday'
              )
          end.to output("Dr. Kim is available\nDr. May is available\n").to_stdout
        end
      end

      describe 'and day is 2' do
        it 'returns doctors ON in Tuesday' do
          expect do
            FindDoctor
              .new
              .invoke(
                'by_day',
                [],
                type: 'csv',
                path: './doctors.csv',
                day: '2'
              )
          end.to output("Dr. Adamski is available\nDr. May is available\n").to_stdout
        end
      end
    end
  end
end
