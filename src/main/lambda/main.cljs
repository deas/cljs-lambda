(ns lambda.main
  (:require
   [clojure.string :as str]
   [cljs.core.async :refer [go <! >! chan put! close!]]
   ["aws-sdk" :as aws]))

(defn start [] (pr "Dev Started"))

(defn reload [] (pr "Dev Reloaded"))

(def ^js s3 (new (.-S3 aws)))

(def ^js ec2 (new (.-EC2 aws)))

(def base-response {:headers {"Content-Type" "application/json"}})

;; https://purelyfunctional.tv/mini-guide/core-async-code-style/
(defn <<< [f & args]
  (let [c (chan)]
    (apply f (concat args [(fn [err val]
                             (println "Got err = " err ", val = " val)
                             (put! c
                                   (if err
                                     {:error (js->clj err)}
                                     (js->clj val :keywordize-keys true)))
                             #_(if (nil? val)
                                 (close! c)
                                 (put! c val)))]))
    c))


(defn s3-list-buckets [callback]
  (.listBuckets s3 callback))

(defn ec2-describe-instances [params callback]
  (println "Describe with params" params)
  (.describeInstances ec2 (clj->js params) callback))

(defn ec2-stop-instances [params callback]
  (println "Stop with params" params)
  (.stopInstances ec2 (clj->js params) callback))

(defn ec2-start-instances [params callback]
  (println "Start with params" params)
  (.startInstances ec2 (clj->js params) callback))

#_(defn list-buckets [callback]
    (go (let [buckets-resp (<! (<<< s3-list-buckets))]
          (callback buckets-resp))))

(defn stop-tagged-instances [params dry-run callback]
  (go (let [desc-resp (<! (<<< ec2-describe-instances params))
            inst-ids (->> (:Reservations desc-resp)
                          (map :Instances)
                          flatten
                          (map :InstanceId))
            stopped-resp (if (seq inst-ids)
                           (<! (<<< ec2-stop-instances {:DryRun dry-run
                                                        :InstanceIds inst-ids}))
                           {:message "No instances matching"})]
        (callback stopped-resp))))

(defn start-tagged-instances [params dry-run callback]
  (go (let [desc-resp (<! (<<< ec2-describe-instances params))
            inst-ids (->> (:Reservations desc-resp)
                          (map :Instances)
                          flatten
                          (map :InstanceId))
            started-resp (if (seq inst-ids)
                           (<! (<<< ec2-start-instances {:DryRun dry-run
                                                         :InstanceIds inst-ids}))
                           {:message "No instances matching"})]
        (callback started-resp))))

(defn enable-aws-logging! []
  (set! (.. aws/config -logger) js/console)
  (println "Using AWS logging" (some? (.-logger  aws/config))))

(defn json [obj]
  (->> obj
       clj->js
       (.stringify js/JSON)))

;; Main export
;; https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html#nodejs-prog-model-handler-callback
(defn handle-stop [js-event context callback]
  (println "Got event" js-event)
  (enable-aws-logging!)
  (let [event (js->clj js-event :keywordize-keys true)
        dry-run (or (:DryRun event) false)
        ;; debug (or (:Debug event) false)
        tag-keys (or (:TagKeys event) ["stop-daily"])
        def-filters [{:Name "instance-state-name" :Values ["running"]}]
        filters (conj def-filters {:Name "tag-key" :Values tag-keys})]
    (stop-tagged-instances
     {:Filters filters}
     dry-run
     (fn [response]
       (callback
        nil
        (clj->js
         (assoc base-response :statusCode 200 :body (json response))))))))

;; Main export
(defn handle-start [js-event context callback]
  (println "Got event" js-event)
  (enable-aws-logging!)
  #_(when debug
      (enable-aws-logging!))
  (let [event (js->clj js-event :keywordize-keys true)
        dry-run (or (:DryRun event) false)
        tag-keys (or (:TagKeys event) ["start-daily"])
        def-filters [{:Name "instance-state-name" :Values ["stopped"]}]
        filters (conj def-filters {:Name "tag-key" :Values tag-keys})]
    (start-tagged-instances
     {:Filters filters}
     dry-run
     (fn [response]
       (callback
        nil
        (clj->js
         (assoc base-response :statusCode 200 :body (json response))))))))

(comment

  (handle-stop (clj->js {:DryRun true
                         :TagKeys ["stop-wips"]})
               nil
               (fn [err resp]
                 (if err
                   (println "err" err)
                   (println "resp" resp))))
  (handle-start (clj->js {;; :DryRun true
                          :TagKeys ["start-daily"]})
                nil
                (fn [err resp]
                  (if err
                    (println "err" err)
                    (println "resp" resp))))

  ;; (go (println (<! (to-chan))))
  )