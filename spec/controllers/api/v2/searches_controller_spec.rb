require 'spec_helper'

describe Api::V2::SearchesController do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_params) do
    { affiliate: 'nps.gov',
      access_key: 'basic_key',
      format: 'json',
      api_key: 'myawesomekey',
      query: 'api',
      query_not: 'excluded',
      query_or: 'alternative',
      query_quote: 'barack obama',
      filetype: 'pdf',
      filter: '2',
      sort_by: 'date' }
  end
  let(:query_params) do
    { query: 'api',
      query_not: 'excluded',
      query_or: 'alternative',
      query_quote: 'barack obama',
      file_type: 'pdf',
      filter: '2' }
  end

  describe '#blended' do
    before do
      expect(Affiliate).to receive(:find_by_name).and_return(affiliate)
      search = double('search', as_json: { foo: 'bar'}, modules: %w(AIDOC NEWS))
      expect(ApiBlendedSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
      expect(search).to receive(:run)
      expect(SearchImpression).to receive(:log).with(search,
                                                     'blended',
                                                     hash_including('query'),
                                                     be_a_kind_of(ActionDispatch::Request))

      get :blended, params: search_params
    end

    it { is_expected.to respond_with :success }

    it 'returns search JSON' do
      expect(JSON.parse(response.body)['foo']).to eq('bar')
    end
  end

  describe '#azure' do
    context 'when the search options are not valid' do
      before { get :azure, params: search_params.except(:api_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiAzureSearch, as_json: { foo: 'bar'}, modules: %w(AWEB)) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiAzureSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'azure',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :azure, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        expect(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :azure, params: search_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  describe '#azure_web' do
    context 'when the search options are not valid' do
      before { get :azure, params: search_params.except(:api_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiAzureCompositeWebSearch, as_json: { foo: 'bar'}, modules: %w(AZCW)) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiAzureCompositeWebSearch).to receive(:new).
          with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'azure_web',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :azure_web, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        expect(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :azure_web, params: search_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  describe '#azure_image' do
    context 'when the search options are not valid' do
      before { get :azure, params: search_params.except(:api_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiAzureCompositeImageSearch, as_json: { foo: 'bar'}, modules: %w(AZCI)) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiAzureCompositeImageSearch).to receive(:new).
          with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'azure_image',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :azure_image, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        expect(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :azure_image, params: search_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  describe '#gss' do
    let(:gss_params) { search_params.merge({ cx: 'my-cx' }) }

    context 'when the search options are not valid' do
      before do
        get :gss, params: gss_params.except(:cx, :api_key)
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('api_key must be present')
        expect(errors).to include('cx must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiGssSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiGssSearch).to receive(:new).with(hash_including(query: 'api')).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'gss',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :gss, params: gss_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        expect(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :gss, params: gss_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  describe '#i14y' do
    context 'when the search options are not valid' do
      before do
        get :i14y,
            params: {
              affiliate: 'nps.gov',
              format: 'json',
              query: 'api'
            }
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { instance_double(ApiI14ySearch, as_json: { foo: 'bar' }, modules: %w[I14Y]) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(ApiI14ySearch).to receive(:new).with(hash_including(query: 'api')).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'i14y',
                                                      hash_including('query'),
                                                      be_a_kind_of(ActionDispatch::Request))

        get :i14y, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'passes the correct options to its ApiI14ySearch object' do
        expect(assigns(:search_options).attributes).to include({ access_key: 'basic_key',
                                                                 affiliate: affiliate,
                                                                 enable_highlighting: true,
                                                                 file_type: 'pdf',
                                                                 filter: '2',
                                                                 limit: 20,
                                                                 next_offset_within_limit: true,
                                                                 offset: 0,
                                                                 query: 'api',
                                                                 query_not: 'excluded',
                                                                 query_or: 'alternative',
                                                                 query_quote: 'barack obama',
                                                                 sort_by: 'date' })
      end

      context 'when an audience filter is present' do
        let(:params_with_audience) { search_params.merge(audience: 'everyone') }

        it 'passes the audience filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_audience
          expect(assigns(:search_options).attributes).to include({ audience: 'everyone' })
        end
      end

      context 'when a content_type filter is present' do
        let(:params_with_content_type) { search_params.merge(content_type: 'article') }

        it 'passes the content_type filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_content_type
          expect(assigns(:search_options).attributes).to include({ content_type: 'article' })
        end
      end

      context 'when a mime_type filter is present' do
        let(:params_with_mime_type) { search_params.merge(mime_type: 'application/pdf') }

        it 'passes the mime_type filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_mime_type
          expect(assigns(:search_options).attributes).to include({ mime_type: 'application/pdf' })
        end
      end

      context 'when a searchgov_custom filter is present' do
        let(:params_with_searchgov_custom) { search_params.merge(searchgov_custom1: 'customOne, customTwo') }

        it 'passes the searchgov_custom filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_searchgov_custom
          expect(assigns(:search_options).attributes).to include({ searchgov_custom1: 'customOne, customTwo' })
        end
      end

      context 'when a tags filter is present' do
        let(:params_with_tags) { search_params.merge(tags: 'tag from params') }

        it 'passes the tags filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_tags
          expect(assigns(:search_options).attributes).to include({ tags: 'tag from params' })
        end
      end
    end

    context 'when a routed query term is matched' do
      before do
        allow(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :i14y, params: search_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  describe '#video' do
    context 'when the search options are not valid' do
      before do
        get :video,
            params: {
              affiliate: 'nps.gov',
              format: 'json',
              query: 'api'
            }
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiVideoSearch, as_json: { foo: 'bar'}, modules: %w(VIDS)) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiVideoSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'video',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :video, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        expect(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :video, params: search_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  describe '#docs' do
    let(:docs_params) { search_params.merge({ dc: 1 }) }

    context 'when the search options are not valid' do
      before { get :docs, params: docs_params.except(:dc) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['dc must be present'])
      end
    end

    context 'when the search options are valid, the affiliate is using BingV6, and the collection is deep' do
      let!(:search) { double(ApiI14ySearch, as_json: { foo: 'bar'}, modules: %w(I14Y)) }
      let!(:document_collection) { double(DocumentCollection, too_deep_for_bing?: true) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(affiliate).to receive(:search_engine).and_return('BingV6')

        expect(DocumentCollection).to receive(:find).and_return(document_collection)

        expect(ApiI14ySearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'docs',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :docs, params: docs_params
      end

      it { is_expected.to respond_with :success }

      it 'uses I14y' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the affiliate is using Google' do
      let!(:search) { double(ApiGoogleDocsSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }

      before do
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(affiliate).to receive(:search_engine).and_return('Google')

        expect(ApiGoogleDocsSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                       'docs',
                                                       hash_including('query'),
                                                       be_a_kind_of(ActionDispatch::Request))

        get :docs, params: docs_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        expect(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :docs, params: docs_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end
end
