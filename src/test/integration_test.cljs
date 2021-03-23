(ns integration-test
  (:require [cljs.test
             :refer (deftest async is testing use-fixtures run-tests)
             ;; :refer-macros [deftest is testing run-tests]
             ]
            [lambda.main :refer (list-buckets stop-tagged-instances handle-stop enable-aws-logging!)]))

(defmethod cljs.test/report [:cljs.test/default :end-run-tests] [m]
  (if (cljs.test/successful? m)
    (println "Success!")
    (println "FAIL")))

(defn logging-test-fixture [f]
  ;; (enable-aws-logging!)
  (f)
  )


;; Logs do no appear in tests?
(enable-console-print!)
(enable-aws-logging!)

;; TODO: Fixture breaks tests with node?
;; (use-fixtures :once logging-test-fixture)

(deftest handler-test
  (testing "Handing stop works"
    (async done
           (let [js-event (clj->js {:TagKeys "stop-daily"
                                    :DryRun true})
                 context nil
                 callback (fn [response]
                            (is (nil? (:error response)) (str response))
                            (done))]
             (handle-stop js-event context callback))))

  #_(testing "List buckets works"
      (async done
             (let [callback (fn [response]
                              (is (nil? (:error response)) (str response))
            ;; (is (not= nil response))
                              (done))]
               (list-buckets callback)))))