import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServices {

  // ApiServices._();
  // ApiServices apiServices = ApiServices();

  Map<String,String> head = {"Content-Type" : "application/json"};

  String url = "https://www.structasofts.com/api/";

  // // Signup
  // Future<http.Response> signup({required String fullname,required String email,required String phonenumber,required String pwd,required String cp}) async{
  //   http.Response response;
  //
  //   final uri = Uri.parse( url + "registerapi.php");
  //   print("Sign up : $uri");
  //
  //   response = await  http.post(
  //     uri,
  //     headers: head,
  //     body: jsonEncode({
  //       "fullname":fullname,
  //       "mail":email,
  //       "phone":phonenumber,
  //       "pwd":pwd,
  //       "confirmpassword":cp
  //     }),
  //   );
  //   return response;
  // }

// log out

  Future<http.Response> login({required String email}) async {
    final uri = Uri.parse(url + "loginapi.php");

    // Standard PHP APIs usually expect Form Data, not JSON bodies
    // Note: We are NOT using jsonEncode here and NOT using application/json headers
    try {
      final response = await http.post(
          uri,
          body: {
            "email": email, // If the server says "email required", ensure this key matches exactly what PHP looks for
          }
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Leave Type
  Future<http.Response> fetchRawLeaveTypes() async {
    http.Response response;
    final uri = Uri.parse(url+ "selectLeaveType.php");

       response = await http.get(uri);

    return response;
  }


  //apply leave
Future<http.Response> applyleave ({
    required String empname,
    required String applieddate,
    required String leavetype,
    required String fromdate,
    required String fromday,
    required String todate,
    required String today,
    required String remark,
    required String attachfile,
    required String user_id,
})async{
    http.Response response;
    final uri = Uri.parse(url+ "applyleaveapi.php");
    print(" applyleave uri $uri");
    
    response = await http.post(
        uri,
        headers: head,
        body: jsonEncode({
          "empname":empname,
          "applieddate":applieddate,
          "leavetype":leavetype,
          "fromdate":fromdate,
          "fromday":fromday,
          "todate":todate,
          "today":today,
          "remark":remark,
          "attachfile":attachfile,
          "user_id":user_id,
        })
    );
    return response;
}

    // Expense Categoty
Future<http.Response> expenseCategory() async{
    http.Response response;
    final uri = Uri.parse(url+"selectExpencesCategory.php");
    print(" expenseCategory uri $uri");

    response = await http.get(uri);
    return response;
}

    // field Employee Sechedule Visit
Future<http.Response> fieldEmployeeScheduleVisit({
    required String clientname,
    required String date,
    required String time,
    required String location,
    required String address,
    required String visitpurpose,
    required String contactperson,
    required String contactno,
    required String meetingagenda,
    required String additionalnotes,
    required String user_id,
}) async{
    http.Response reponse;
    final uri = Uri.parse(url+"scheduleVisitApi.php");
    print(" fieldEmployeeScheduleVisit uri $uri");

    reponse = await http.post(
      uri,
      headers: head,
      body: jsonEncode({
        "clientname":clientname,
        "date":date,
        "time":time,
        "location":location,
        "address":address,
        "visitpurpose":visitpurpose,
        "contactperson":contactperson,
        "contactno":contactno,
        "meetingagenda":meetingagenda,
        "additionalnotes":additionalnotes,
        "user_id": user_id,
      })
    );
    return reponse;
}

    // Expense Reimbursement
Future<http.Response> ExpenseReimbursement({
    required String expencestitle,
    required String category,
    required String amount,
    required String expencesdate,
    required String uploadbillphoto,
    required String description,
    required String user_id,
}) async{
    http.Response response;

    final uri=Uri.parse(url+"ExpencesReimbursementapi.php");
    print("ExpenseReimbursement uri $uri");

    response = await http.post(
      uri,
      headers: head,
      body: jsonEncode({
        "expencestitle" : expencestitle,
        "category" : category,
        "amount" : amount,
        "expencesdate" :expencesdate,
        "uploadbillphoto" : uploadbillphoto,
        "description" : description,
        "user_id" : user_id,
      })
    );
    return response;
}

   // Experience letter
Future<http.Response>  ExperienceLetter({
    required String purpose_of_req,
    required String additional_information,
    required String user_id,
}) async{
    http.Response response;

    final uri = Uri.parse(url+"ExperienceLetterReqApi.php");
    print("ExperienceLetter uri $uri");

    response = await http.post(
      uri,
      headers: head,
     body: jsonEncode({
       "purpose_of_req" : purpose_of_req,
       "additional_information" : additional_information,
       "user_id" : user_id
     })
    );
  return response;

}


 //salary certificate
Future<http.Response> SalaryCertificate({
    required String user_id,
    required String month,
    required String purpose_of_req,
    required String additional_information,
})async{
    http.Response response;
    
    final uri =Uri.parse(url+"salarycertificateReqApi.php");
    print("SalaryCertificate uri $uri");

    response = await http.post(
      uri,
      headers: head,
      body: jsonEncode({
        "user_id" : user_id,
        "month" : month,
        "purpose_of_req" : purpose_of_req,
        "additional_information" : additional_information
      })
    );
    return response;
}

    // Shift_Scheduletype
Future<http.Response> ShiftScheduleChangeRequest()async{
    http.Response response;
    final uri =Uri.parse(url+"SelectShifttype.php");
    print("ShiftScheduleChangeRequest uri $uri");

    response = await http.get(uri);
    return response;
}

  // Shift Schedule change Request

Future<http.Response> ShiftScheduleChangeRequestApi({
    required String user_id,
    required String selectshift,
    required String date,
    required String reason,
    required String additionalnote,
}) async{
    http.Response response;

    final uri = Uri.parse(url + "shiftschedulechangeReq.php");
    print("ShiftScheduleChangeRequestApi uri $uri");

    response = await http.post(
      uri,
      headers: head,
      body: jsonEncode({
        "user_id" : user_id,
        "selectshift" : selectshift,
        "date" : date,
        "reason" : reason,
        "additionalnote" : additionalnote
      })
    );
    return response;
}


 // Employee Profile Data
Future<http.Response> EmployeeProfileData(String userId)async{
    http.Response response;
    
    final uri =Uri.parse(url + "getEmployee.php?id=$userId");
    print("EmployeeProfileData uri $uri");

    response = await http.get(uri);
    return response;
}


  // Fetch Company Location
  Future<http.Response> FetchCompanylocation() async{
    http.Response response;

    final uri = Uri.parse(url + "getLocationData.php");
    print("FetchCompanylocation uri $uri");

    response = await http.get(uri);
    return response;

  }


  // Fetch Deily task
 Future<http.Response> FetchDailyTask() async{
    http.Response response;

    final uri = Uri.parse( url + "task_api.php");
    print("FetchDailyTask uri =====> $uri");
    response = await http.get(uri);
    return response;
 }


 // Future<http.Response> CompleteDailyTask () async {
 //    http.Response response;
 //
 //    final uri = Uri.parse(url +"completeTaskApi.php");
 //    print("CompleteDailyTask Uri ======> $uri");
 //    response = await htt
 // }
  

   // Advance Salary request
Future<http.Response> AdvanceSalaryrequest ({
    required String user_id,
    required String advance_amount,
    required String required_date,
    required String payment_method,
    required String reason,
    required String current_salary,
}) async{
    http.Response response;

    final uri = Uri.parse(url + "advancesalaryreqapi.php");
    print("Advance Salary Request ====> $uri");
    response = await http.post(
      uri,
      headers: head,
      body: jsonEncode({
        "user_id" : user_id,
        "advance_amount" : advance_amount,
        "required_date" : required_date,
        "payment_method" : payment_method,
        "reason" : reason,
        "current_salary" : current_salary
      })
    );
    return response;
}

// Holidat List
Future<http.Response> HolidayList () async{
    http.Response response;
    
    final uri = Uri.parse(url + "getholidayListapi.php");
    print("Uri HolidayList =====> $uri");

    response = await http.get(uri);
    return response;
    
}

// Review Task list
Future<http.Response> ReviewTaskList()  async{
    http.Response response;
    
    final uri =Uri.parse(url + "review_task_api.php");
    print("Uri ReviewTasklist ===> $uri");

    response = await http.get(uri);
    return response;
}

// select Workcategory (fild employee)
  Future<http.Response> SelectworkCategory()  async{
    http.Response response;

    final uri =Uri.parse(url + "selectworkcategoryapi.php");
    print("Uri ReviewTasklist ===> $uri");

    response = await http.get(uri);
    return response;
  }

  //resechedule visit
Future<http.Response> Reschedulevisit ({
    required String visit_id,
    required String user_id,
    required String new_date,
    required String new_time,
    required String reason,
}) async{
    http.Response response;
    
    final uri = Uri.parse(url +"rescheduleVisitApi.php");
    print("uri Reschedulevisit=======> $uri");
    response = await http.post(
      uri,
      headers: head,
      body: jsonEncode(
        {
          "visit_id" : visit_id,
          "user_id" : user_id,
          "new_date" : new_date,
          "new_time" : new_time,
          "reason" : reason,
        }
      )
    );
    return response;
}


 // Check - in and Check out
  Future<http.Response> attendance({
    required String user_id,
    required String type,
  }) async {
    http.Response response;
    final uri = Uri.parse(url + "attendance_api.php");
    print("attendance $uri");
    response = await http.post(
      uri,
      body: {
        "user_id": user_id,
        "type": type,
      },
    );
    return response;
  }

  //  atandance History
  Future<http.Response> AttandanceHistory(String userId)async{
    http.Response response;

    final uri =Uri.parse(url + "attendance_history_api.php?user_id=$userId");
    print("AttandanceHistory uri $uri");

    response = await http.get(uri);
    return response;
  }


  Future<http.Response>  getDistance(String userId) async{
    http.Response response;
    final uri = Uri.parse(url + 'getdistanceapi.php?user_id=$userId');
    print('get distance $uri');
    response = await http.get(uri);
    return response;
  }

  Future<http.Response> getattendanceRules(String userId)async{
    http.Response response;
    final uri = Uri.parse(url + 'api_attendance_status.php?use_id=$userId');
    print('get attendance rules $uri');
    response = await http.get(uri);
    return response;
  }


}



