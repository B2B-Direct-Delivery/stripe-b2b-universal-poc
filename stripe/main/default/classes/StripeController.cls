public with sharing class StripeController {

    public final String originUrl { get; set; }
    public final String clientSecret { get; set; }

    public StripeController() {
        this.originUrl = getCommunityUrl('stripetest');
        // TODO this is just for testing, we'll need to get it a different way
        this.clientSecret = getClientSecret();
    }

    private final static Pattern SITE_URL_PATTERN = Pattern.compile('^(https:\\/\\/[^\\/]+).*$');

    private String getCommunityUrl(String communityName) {
        for (ConnectApi.Community community :
                ConnectApi.Communities.getCommunities().communities) {
            if (community.name == communityName) {
                Matcher matcher = SITE_URL_PATTERN.matcher(
                        community.siteUrl);
                if (matcher.find() && matcher.groupCount() > 0) {
                    return matcher.group(1);
                }
                break;
            }
        }
        return null;
    }

    private String getClientSecret() {
        stripeGC__Stripe_Account__c stripeAccount = [SELECT Id FROM stripeGC__Stripe_Account__c LIMIT 1]; // TODO put a more specific WHERE clause in this query!

        stripeGC.RawInvocableParameters params = new stripeGC.RawInvocableParameters();
        stripeGC.RawInvocableParameters[] paramsWrapper = new stripeGC.RawInvocableParameters [] {params};

        Map<String, String> paymentIntentParams = new Map<String, String> {
                'amount' => '1400',
                'currency' => 'eur'
        };

        params.accountId = stripeAccount.Id;
        params.endpoint = '/v1/payment_intents';
        params.method = 'POST';
        params.requestBody = convertParams(paymentIntentParams);

        String[] results = stripeGC.AgnosticInvocable.callStripeEndpoint(paramsWrapper);

        Map<String, Object> stripeResult = (Map<String, Object>) JSON.deserializeUntyped(results[0]);
        String secret = (String) stripeResult.get('client_secret');

        return secret;
    }

    private static String convertParams(Map<String, String> params) {
        List<String> values = new List<String>();
        for (String k : params.keySet()) {
            values.add(k + '=' + params.get(k));
        }
        return String.join(values, '&');
    }

}