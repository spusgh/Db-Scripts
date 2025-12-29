
/**
 * Apache Storm Topologies for XYZ_Financials_Securities
 * Real-time event processing with guaranteed message delivery
 */

package com.xyz.financials.storm;

import org.apache.storm.Config;
import org.apache.storm.LocalCluster;
import org.apache.storm.StormSubmitter;
import org.apache.storm.topology.TopologyBuilder;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.task.OutputCollector;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.kafka.spout.*;
import org.apache.storm.kafka.bolt.KafkaBolt;

import java.util.*;

// ==========================================
// DATA MODELS
// ==========================================

class Payment {
    int paymentId;
    int loanId;
    long paymentDate;
    double paymentAmount;
    double principalAmount;
    double interestAmount;
    String paymentStatus;
}

class Loan {
    int loanId;
    int customerId;
    double remainingBalance;
    double interestRate;
    String status;
    long nextPaymentDate;
}

class DelinquencyAlert {
    int loanId;
    int customerId;
    int daysPastDue;
    String severity;
    long alertTime;
}

// ==========================================
// TOPOLOGY 1: Real-time Payment Processing
// ==========================================

public class PaymentProcessingTopology {
    
    // Kafka Spout for reading payments
    static class PaymentSpout extends BaseRichSpout {
        SpoutOutputCollector collector;
        
        @Override
        public void open(Map conf, TopologyContext context, SpoutOutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void nextTuple() {
            // Kafka spout will be configured separately
            // This is a placeholder for the logic
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declare(new Fields("payment_id", "loan_id", "payment_amount", 
                "principal_amount", "interest_amount", "payment_status"));
        }
    }
    
    // Bolt to validate payments
    static class PaymentValidationBolt extends BaseRichBolt {
        OutputCollector collector;
        
        @Override
        public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void execute(Tuple tuple) {
            try {
                int paymentId = tuple.getIntegerByField("payment_id");
                int loanId = tuple.getIntegerByField("loan_id");
                double paymentAmount = tuple.getDoubleByField("payment_amount");
                String paymentStatus = tuple.getStringByField("payment_status");
                
                // Validation logic
                if (paymentAmount > 0 && paymentStatus != null) {
                    // Payment is valid
                    collector.emit(tuple, new Values(paymentId, loanId, paymentAmount, "VALID"));
                    collector.ack(tuple);
                } else {
                    // Payment is invalid
                    collector.emit(tuple, new Values(paymentId, loanId, paymentAmount, "INVALID"));
                    collector.ack(tuple);
                }
            } catch (Exception e) {
                collector.fail(tuple);
            }
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declare(new Fields("payment_id", "loan_id", "payment_amount", "validation_status"));
        }
    }
    
    // Bolt to update loan balances
    static class LoanBalanceUpdateBolt extends BaseRichBolt {
        OutputCollector collector;
        Map<Integer, Double> loanBalances = new HashMap<>();
        
        @Override
        public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void execute(Tuple tuple) {
            try {
                String validationStatus = tuple.getStringByField("validation_status");
                
                if ("VALID".equals(validationStatus)) {
                    int loanId = tuple.getIntegerByField("loan_id");
                    double paymentAmount = tuple.getDoubleByField("payment_amount");
                    
                    // Update balance (in real impl, this would query a DB)
                    Double currentBalance = loanBalances.getOrDefault(loanId, 0.0);
                    double newBalance = currentBalance - paymentAmount;
                    loanBalances.put(loanId, newBalance);
                    
                    collector.emit(tuple, new Values(loanId, newBalance));
                }
                
                collector.ack(tuple);
            } catch (Exception e) {
                collector.fail(tuple);
            }
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declare(new Fields("loan_id", "new_balance"));
        }
    }
    
    public static void main(String[] args) throws Exception {
        TopologyBuilder builder = new TopologyBuilder();
        
        // Configure Kafka spout
        KafkaSpoutConfig<String, String> kafkaConfig = KafkaSpoutConfig.builder(
            "localhost:9092", "payments")
            .setGroupId("storm-payment-processor")
            .setFirstPollOffsetStrategy(KafkaSpoutConfig.FirstPollOffsetStrategy.LATEST)
            .build();
        
        // Build topology
        builder.setSpout("payment-spout", new KafkaSpout<>(kafkaConfig), 4);
        builder.setBolt("payment-validation", new PaymentValidationBolt(), 8)
            .shuffleGrouping("payment-spout");
        builder.setBolt("balance-update", new LoanBalanceUpdateBolt(), 8)
            .fieldsGrouping("payment-validation", new Fields("loan_id"));
        builder.setBolt("kafka-sink", new KafkaBolt<>(), 4)
            .shuffleGrouping("balance-update");
        
        Config config = new Config();
        config.setDebug(false);
        config.setNumWorkers(4);
        config.setMessageTimeoutSecs(30);
        
        if (args != null && args.length > 0) {
            StormSubmitter.submitTopology(args[0], config, builder.createTopology());
        } else {
            LocalCluster cluster = new LocalCluster();
            cluster.submitTopology("payment-processing", config, builder.createTopology());
            Thread.sleep(60000);
            cluster.shutdown();
        }
    }
}

// ==========================================
// TOPOLOGY 2: Delinquency Detection
// ==========================================

public class DelinquencyDetectionTopology {
    
    // Bolt to check for delinquent loans
    static class DelinquencyCheckBolt extends BaseRichBolt {
        OutputCollector collector;
        
        @Override
        public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void execute(Tuple tuple) {
            try {
                int loanId = tuple.getIntegerByField("loan_id");
                int customerId = tuple.getIntegerByField("customer_id");
                long nextPaymentDate = tuple.getLongByField("next_payment_date");
                String status = tuple.getStringByField("status");
                
                if ("Active".equals(status)) {
                    long currentTime = System.currentTimeMillis();
                    long daysPastDue = (currentTime - nextPaymentDate) / (1000 * 60 * 60 * 24);
                    
                    if (daysPastDue > 0) {
                        String severity = determineSeverity(daysPastDue);
                        collector.emit(tuple, new Values(loanId, customerId, daysPastDue, severity));
                    }
                }
                
                collector.ack(tuple);
            } catch (Exception e) {
                collector.fail(tuple);
            }
        }
        
        private String determineSeverity(long daysPastDue) {
            if (daysPastDue > 90) return "CRITICAL";
            if (daysPastDue > 60) return "HIGH";
            if (daysPastDue > 30) return "MEDIUM";
            return "LOW";
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declare(new Fields("loan_id", "customer_id", "days_past_due", "severity"));
        }
    }
    
    // Bolt to route alerts based on severity
    static class AlertRoutingBolt extends BaseRichBolt {
        OutputCollector collector;
        
        @Override
        public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void execute(Tuple tuple) {
            try {
                String severity = tuple.getStringByField("severity");
                
                // Route to different streams based on severity
                if ("CRITICAL".equals(severity)) {
                    collector.emit("critical-stream", tuple, tuple.getValues());
                } else if ("HIGH".equals(severity)) {
                    collector.emit("high-stream", tuple, tuple.getValues());
                } else {
                    collector.emit("normal-stream", tuple, tuple.getValues());
                }
                
                collector.ack(tuple);
            } catch (Exception e) {
                collector.fail(tuple);
            }
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declareStream("critical-stream", new Fields("loan_id", "customer_id", "days_past_due", "severity"));
            declarer.declareStream("high-stream", new Fields("loan_id", "customer_id", "days_past_due", "severity"));
            declarer.declareStream("normal-stream", new Fields("loan_id", "customer_id", "days_past_due", "severity"));
        }
    }
    
    public static void main(String[] args) throws Exception {
        TopologyBuilder builder = new TopologyBuilder();
        
        KafkaSpoutConfig<String, String> kafkaConfig = KafkaSpoutConfig.builder(
            "localhost:9092", "loans")
            .setGroupId("storm-delinquency-detector")
            .build();
        
        builder.setSpout("loan-spout", new KafkaSpout<>(kafkaConfig), 4);
        builder.setBolt("delinquency-check", new DelinquencyCheckBolt(), 8)
            .shuffleGrouping("loan-spout");
        builder.setBolt("alert-routing", new AlertRoutingBolt(), 4)
            .shuffleGrouping("delinquency-check");
        
        // Different bolts for different severity levels
        builder.setBolt("critical-handler", new KafkaBolt<>(), 2)
            .shuffleGrouping("alert-routing", "critical-stream");
        builder.setBolt("high-handler", new KafkaBolt<>(), 2)
            .shuffleGrouping("alert-routing", "high-stream");
        builder.setBolt("normal-handler", new KafkaBolt<>(), 2)
            .shuffleGrouping("alert-routing", "normal-stream");
        
        Config config = new Config();
        config.setNumWorkers(3);
        config.setMaxSpoutPending(1000);
        
        if (args != null && args.length > 0) {
            StormSubmitter.submitTopology(args[0], config, builder.createTopology());
        } else {
            LocalCluster cluster = new LocalCluster();
            cluster.submitTopology("delinquency-detection", config, builder.createTopology());
            Thread.sleep(60000);
            cluster.shutdown();
        }
    }
}

// ==========================================
// TOPOLOGY 3: Fraud Detection
// ==========================================

public class FraudDetectionTopology {
    
    // Bolt to detect suspicious payment patterns
    static class FraudDetectionBolt extends BaseRichBolt {
        OutputCollector collector;
        Map<Integer, List<Double>> recentPayments = new HashMap<>();
        
        @Override
        public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void execute(Tuple tuple) {
            try {
                int loanId = tuple.getIntegerByField("loan_id");
                double paymentAmount = tuple.getDoubleByField("payment_amount");
                
                // Track recent payments
                List<Double> payments = recentPayments.getOrDefault(loanId, new ArrayList<>());
                payments.add(paymentAmount);
                
                // Keep only last 10 payments
                if (payments.size() > 10) {
                    payments.remove(0);
                }
                recentPayments.put(loanId, payments);
                
                // Check for fraud patterns
                boolean isSuspicious = detectFraud(payments, paymentAmount);
                
                if (isSuspicious) {
                    collector.emit(tuple, new Values(loanId, paymentAmount, "SUSPICIOUS"));
                } else {
                    collector.emit(tuple, new Values(loanId, paymentAmount, "NORMAL"));
                }
                
                collector.ack(tuple);
            } catch (Exception e) {
                collector.fail(tuple);
            }
        }
        
        private boolean detectFraud(List<Double> payments, double currentPayment) {
            if (payments.size() < 3) return false;
            
            // Calculate average
            double avg = payments.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            
            // Flag if payment is 3x the average
            return currentPayment > avg * 3;
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declare(new Fields("loan_id", "payment_amount", "fraud_status"));
        }
    }
    
    public static void main(String[] args) throws Exception {
        TopologyBuilder builder = new TopologyBuilder();
        
        KafkaSpoutConfig<String, String> kafkaConfig = KafkaSpoutConfig.builder(
            "localhost:9092", "payments")
            .setGroupId("storm-fraud-detector")
            .build();
        
        builder.setSpout("payment-spout", new KafkaSpout<>(kafkaConfig), 4);
        builder.setBolt("fraud-detection", new FraudDetectionBolt(), 8)
            .fieldsGrouping("payment-spout", new Fields("loan_id"));
        builder.setBolt("alert-sink", new KafkaBolt<>(), 4)
            .shuffleGrouping("fraud-detection");
        
        Config config = new Config();
        config.setNumWorkers(3);
        
        if (args != null && args.length > 0) {
            StormSubmitter.submitTopology(args[0], config, builder.createTopology());
        } else {
            LocalCluster cluster = new LocalCluster();
            cluster.submitTopology("fraud-detection", config, builder.createTopology());
            Thread.sleep(60000);
            cluster.shutdown();
        }
    }
}

// ==========================================
// TOPOLOGY 4: Real-time Metrics Aggregation
// ==========================================

public class MetricsAggregationTopology {
    
    // Bolt to aggregate payment metrics
    static class PaymentMetricsAggregator extends BaseRichBolt {
        OutputCollector collector;
        Map<String, MetricAccumulator> windowMetrics = new HashMap<>();
        
        class MetricAccumulator {
            int count = 0;
            double totalAmount = 0;
            double totalPrincipal = 0;
            double totalInterest = 0;
        }
        
        @Override
        public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
            this.collector = collector;
        }
        
        @Override
        public void execute(Tuple tuple) {
            try {
                String window = getCurrentWindow(); // 5-minute windows
                double paymentAmount = tuple.getDoubleByField("payment_amount");
                double principalAmount = tuple.getDoubleByField("principal_amount");
                double interestAmount = tuple.getDoubleByField("interest_amount");
                
                MetricAccumulator acc = windowMetrics.getOrDefault(window, new MetricAccumulator());
                acc.count++;
                acc.totalAmount += paymentAmount;
                acc.totalPrincipal += principalAmount;
                acc.totalInterest += interestAmount;
                windowMetrics.put(window, acc);
                
                // Emit metrics every 100 tuples
                if (acc.count % 100 == 0) {
                    collector.emit(new Values(window, acc.count, acc.totalAmount, 
                        acc.totalPrincipal, acc.totalInterest));
                }
                
                collector.ack(tuple);
            } catch (Exception e) {
                collector.fail(tuple);
            }
        }
        
        private String getCurrentWindow() {
            long currentTime = System.currentTimeMillis();
            long windowSize = 5 * 60 * 1000; // 5 minutes
            long windowStart = (currentTime / windowSize) * windowSize;
            return String.valueOf(windowStart);
        }
        
        @Override
        public void declareOutputFields(org.apache.storm.topology.OutputFieldsDeclarer declarer) {
            declarer.declare(new Fields("window", "count", "total_amount", 
                "total_principal", "total_interest"));
        }
    }
    
    public static void main(String[] args) throws Exception {
        TopologyBuilder builder = new TopologyBuilder();
        
        KafkaSpoutConfig<String, String> kafkaConfig = KafkaSpoutConfig.builder(
            "localhost:9092", "payments")
            .setGroupId("storm-metrics-aggregator")
            .build();
        
        builder.setSpout("payment-spout", new KafkaSpout<>(kafkaConfig), 4);
        builder.setBolt("metrics-aggregator", new PaymentMetricsAggregator(), 4)
            .shuffleGrouping("payment-spout");
        builder.setBolt("metrics-sink", new KafkaBolt<>(), 2)
            .shuffleGrouping("metrics-aggregator");
        
        Config config = new Config();
        config.setNumWorkers(2);
        config.put(Config.TOPOLOGY_TICK_TUPLE_FREQ_SECS, 60);
        
        if (args != null && args.length > 0) {
            StormSubmitter.submitTopology(args[0], config, builder.createTopology());
        } else {
            LocalCluster cluster = new LocalCluster();
            cluster.submitTopology("metrics-aggregation", config, builder.createTopology());
            Thread.sleep(60000);
            cluster.shutdown();
        }
    }
}

// ==========================================
// CONFIGURATION FILE (storm.yaml)
// ==========================================

/*
# Storm cluster configuration
storm.zookeeper.servers:
  - "localhost"

storm.zookeeper.port: 2181

nimbus.seeds: ["localhost"]

supervisor.slots.ports:
  - 6700
  - 6701
  - 6702
  - 6703

# Performance tuning
topology.workers: 4
topology.max.spout.pending: 1000
topology.message.timeout.secs: 30
topology.executor.receive.buffer.size: 16384
topology.executor.send.buffer.size: 16384
topology.transfer.buffer.size: 1024

# Kafka integration
kafka.broker.properties:
  bootstrap.servers: "localhost:9092"
  security.protocol: "PLAINTEXT"
*/