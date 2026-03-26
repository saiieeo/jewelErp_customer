enum Environment { dev, prod }

class AppConfig {
  // Set to prod to point to AWS
  static const Environment currentEnv = Environment.prod;

  static String get baseUrl {
    switch (currentEnv) {
      case Environment.dev:
        return 'http://10.0.2.2:8080/api/customer-app'; 
      case Environment.prod:
        // Your live AWS ALB Endpoint
        return 'http://jewel-erp-alb-2124014483.ap-south-1.elb.amazonaws.com/api/customer-app'; 
    }
  }
}