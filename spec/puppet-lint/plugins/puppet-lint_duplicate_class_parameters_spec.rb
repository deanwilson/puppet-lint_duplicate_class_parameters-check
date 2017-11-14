require 'spec_helper'

describe 'duplicate_class_parameters' do

  context 'class with no parameters' do
   let(:code) do
      <<-EOS
        class file_resource {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      EOS
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class without duplicate parameter' do
    let(:code) do
      <<-EOS
        class file_resource(
          $unique = 'bar',
        ) {

          file { '/tmp/my-file':
            mode => '0600',
          }

          $baz = 'xxzzy'
        }
      EOS
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with duplicate right hand side' do
    let(:code) do
      <<-EOS
        class duplicated_rhs(
          $nagios_innodb_enable = $sys11mysql,
          $nagios_myisam_enable = $sys11mysql,
        ) {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      EOS
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with type and duplicate right hand side' do
    let(:code) do
      <<-EOS
        class duplicated_rhs(
          Boolean $nagios_innodb_enable = $sys11mysql::params::production_environment,
          Boolean $nagios_myisam_enable = $sys11mysql::params::production_environment,
        ) {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      EOS
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  # Examples that should fail specs

  context 'class with duplicate parameters' do
    let(:msg) { 'found duplicate parameter \'duplicated\' in class \'file_resource\'' }
    let(:code) do
      <<-EOS
        class file_resource(
          $duplicated = { 'a' => 1 },
          $duplicated = 'foo',
          $not_unique = 'bar',
          $not_unique = '2nd bar',
          $unique = 'baz'
        ) {

          file { '/tmp/my-file':
            mode => '0600',
          }

          $baz = 'xxzzy'
        }
      EOS
    end

    it 'should detect two problems' do
      expect(problems).to have(2).problems
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(11)
    end

    it 'should create two warnings' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(11)
      expect(problems).to contain_warning(msg.sub('duplicated', 'not_unique')).on_line(5).in_column(11)
    end

  end

  context 'class with type and duplicate parameters' do
    let(:msg) { 'found duplicate parameter \'not_unique\' in class \'duplicated_type\'' }
    let(:code) do
      <<-EOS
        class duplicated_type(
          Boolean $not_unique = true,
          Boolean $not_unique = false,
        ) {

          file { '/tmp/my-file':
            mode => '0600',
          }

          $baz = 'xxzzy'
        }
      EOS
    end

    it 'should detect two problems' do
      expect(problems).to have(1).problems
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(19)
    end
  end

end
