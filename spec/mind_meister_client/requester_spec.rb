describe MindMeisterClient::Requester do
  subject { MindMeisterClient::Requester.new('1625a1388f512a203faa43e8685bcdde', '2d845879a2f2a3b1') }

  describe '#prepare_api_method' do
    it 'prepares mm.maps.getList' do
      expect(subject.prepare_api_method(:maps_get_list)).to eq 'mm.maps.getList'
    end

    it 'prepares mm.auth.getToken' do
      expect(subject.prepare_api_method(:auth_get_token)).to eq 'mm.auth.getToken'
    end

    it 'prepares mm.maps.newFromTemplate' do
      expect(subject.prepare_api_method(:maps_new_from_template)).to eq 'mm.maps.newFromTemplate'
    end
  end


  describe '#api_scope?' do
    describe 'MM API scopes' do
      it 'detects MM API scope for maps_get_list' do
        expect(subject.api_scope?(:maps_get_list)).to be_truthy
      end

      it 'detects MM API scope for auth_get_token' do
        expect(subject.api_scope?(:auth_get_token)).to be_truthy
      end

      it 'detects MM API scope for maps_new_from_template' do
        expect(subject.api_scope?(:maps_new_from_template)).to be_truthy
      end
    end

    describe 'Ruby methods' do
      it 'does not detect MM API scope for each_index' do
        expect(subject.api_scope?(:each_index)).to be_falsey
      end

      it 'does not detect MM API scope for to_i' do
        expect(subject.api_scope?(:to_i)).to be_falsey
      end
    end
  end


  describe '#signed_query_string' do
    it 'creates correct query string' do
      new_params = {
        x: 4,
        h: 6,
        a: 10
      }
      signed_query = subject.signed_query_string(new_params)

      expect(signed_query).to eq 'x=4&h=6&a=10&api_sig=3d9576c5e7068213a40354db62f9fbc3'
    end
  end
end
