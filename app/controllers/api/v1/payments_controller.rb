module Api
  module V1
    
  require 'razorpay'
  class PaymentsController < ApplicationController
  before_action :authenticate_user

  def create
    begin
      Razorpay.setup('rzp_test_MVnQ7EgkysBNE7', 'Wq3y0oDtgDbxHuWYj5ghYEwo')
      amount = params[:amount]
      order = Razorpay::Order.create(amount: amount, currency: 'INR')
      render json: { 
        order_id: order.id,
        order_amount: order.amount ,
        key: "rzp_test_MVnQ7EgkysBNE7"
      }
      rescue Razorpay::Error => e
        render json: { error: e  }, status: :unprocessable_entity
      end
  end

  def verify_payment
    Razorpay.setup('rzp_test_MVnQ7EgkysBNE7', 'Wq3y0oDtgDbxHuWYj5ghYEwo')
    signature_id = params[:signature_id]
    payment_id=params[:payment_id]
    payment = Razorpay::Payment.fetch(payment_id)
    
    amount_paid = payment.amount.to_f / 100
    
    
    if payment.status == 'captured'
      token = request.headers['Authorization']
      @current_user ||= User.find_by(auth_token: token)

      sub = MySubscription.create(user_id: @current_user.id, amount_id: amount_paid)
      
      if sub.save
        req_attempt = 0
        if amount_paid == 1
          req_attempt = 1
        elsif amount_paid == 3
          req_attempt = 3
        else  
          req_attempt = 5
        end
        
        @existing_record = RemainingAttempt.find_by(user_id: @current_user.id)

        if @existing_record
          @existing_record.attempts += req_attempt
          @existing_record.save
        else 
          @new_record = RemainingAttempt.create(user_id: @current_user.id, attempts: req_attempt)
        end
      end

      render json: {msg: "verification: successfull", attempts: @existing_record, amount: amount_paid}, status: :ok
    else
      render json: {msg: "verification: unsuccessfull"}, status: :unprocessable_entity
    end
  end

  def index
    render 'payments/show'
  end



 
    end
  end
end