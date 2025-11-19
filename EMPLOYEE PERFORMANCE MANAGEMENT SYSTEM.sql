SET SERVEROUTPUT ON SIZE UNLIMITED;
DECLARE 
     TYPE employee_info IS RECORD(
        employee_id NUMBER(6),
        employee_name VARCHAR2(50),
        department VARCHAR2(30),
        position VARCHAR2(30)
     );

     TYPE performance_review IS RECORD(
        review_period VARCHAR2(15),
        category VARCHAR2(40),
        score NUMBER(3),
        weight NUMBER(3)
     );
     
     TYPE review_list IS TABLE OF performance_review;
     v_employee employee_info;
     v_reviews review_list;
     v_total_score NUMBER := 0;
     v_max_score NUMBER := 0;
     v_performance_rating NUMBER(5,2);
     v_low_categories NUMBER := 0;
     v_employee_status VARCHAR2(20);

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=====================');
    DBMS_OUTPUT.PUT_LINE(' EMPLOYEE PERFORMANCE MANAGEMENT SYSTEM');
    DBMS_OUTPUT.PUT_LINE('=====================');
    DBMS_OUTPUT.PUT_LINE('');

    -- Employee information
    v_employee.employee_id := 27321;
    v_employee.employee_name := 'Shafi Imam';
    v_employee.department := 'Software Development';
    v_employee.position := 'Senior Developer';

    -- Performance reviews data
    v_reviews := review_list( 
        performance_review('Q1 2024', 'Technical Skills', 92, 25),
        performance_review('Q1 2024', 'Team Collaboration', 88, 20),
        performance_review('Q1 2024', 'Project Delivery', 95, 30),
        performance_review('Q1 2024', 'Communication', 65, 15),      -- Low score
        performance_review('Q1 2024', 'Innovation', 90, 10)
    );

    -- Display employee information
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee.employee_id);
    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_employee.employee_name);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_employee.department);
    DBMS_OUTPUT.PUT_LINE('Position: ' || v_employee.position);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- PERFORMANCE REVIEW SCORES ---');

    -- Process each performance category
    <<review_processing>>
    FOR i IN 1..v_reviews.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(v_reviews(i).category || ' (' || 
                          v_reviews(i).review_period || '): ' || 
                          v_reviews(i).score || '/100' ||
                          ' [Weight: ' || v_reviews(i).weight || '%]');
        
        -- Calculate weighted score
        v_total_score := v_total_score + (v_reviews(i).score * v_reviews(i).weight / 100);
        v_max_score := v_max_score + (100 * v_reviews(i).weight / 100);
        
        -- Check for low performance categories
        IF v_reviews(i).score < 70 THEN
            v_low_categories := v_low_categories + 1;
            DBMS_OUTPUT.PUT_LINE('   ** NEEDS IMPROVEMENT - Development Plan Required **');
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- Determine if employee has performance issues
    IF v_low_categories > 0 THEN
        GOTO has_performance_issues;
    ELSE
        GOTO calculate_rating;
    END IF;

    <<has_performance_issues>>
    DBMS_OUTPUT.PUT_LINE('--- PERFORMANCE STATUS ---');
    DBMS_OUTPUT.PUT_LINE('Low Performing Categories: ' || v_low_categories);
    
    IF v_low_categories >= 3 THEN
        v_employee_status := 'PERFORMANCE_PLAN';
        DBMS_OUTPUT.PUT_LINE('Status: PERFORMANCE IMPROVEMENT PLAN');
        DBMS_OUTPUT.PUT_LINE('Action Required: Immediate manager meeting + HR consultation');
        GOTO end_processing;
    ELSE
        v_employee_status := 'DEVELOPMENT_NEEDED';
        DBMS_OUTPUT.PUT_LINE('Status: DEVELOPMENT AREAS IDENTIFIED');
        DBMS_OUTPUT.PUT_LINE('Action Required: Create personal development plan');
        GOTO calculate_rating;
    END IF;

    <<calculate_rating>>
    IF v_max_score > 0 THEN
        v_performance_rating := (v_total_score / v_max_score) * 100;
        
        DBMS_OUTPUT.PUT_LINE('--- PERFORMANCE SUMMARY ---');
        DBMS_OUTPUT.PUT_LINE('Overall Performance Rating: ' || TO_CHAR(v_performance_rating, '999.99') || '%');
        DBMS_OUTPUT.PUT_LINE('Weighted Total Score: ' || TO_CHAR(v_total_score, '999.99') || '/' || TO_CHAR(v_max_score, '999.99'));
        
        -- Performance classification
        IF v_performance_rating >= 90 THEN
            DBMS_OUTPUT.PUT_LINE('Performance Level: EXCEPTIONAL');
            DBMS_OUTPUT.PUT_LINE('Recommendation: Eligible for promotion & bonus');
        ELSIF v_performance_rating >= 80 THEN
            DBMS_OUTPUT.PUT_LINE('Performance Level: EXCEEDS EXPECTATIONS');
            DBMS_OUTPUT.PUT_LINE('Recommendation: Merit increase + advanced training');
        ELSIF v_performance_rating >= 70 THEN
            DBMS_OUTPUT.PUT_LINE('Performance Level: MEETS EXPECTATIONS');
            DBMS_OUTPUT.PUT_LINE('Recommendation: Standard merit increase');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Performance Level: BELOW EXPECTATIONS');
            DBMS_OUTPUT.PUT_LINE('Recommendation: Performance improvement plan required');
        END IF;
    END IF;

    <<end_processing>>
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=====================');
    DBMS_OUTPUT.PUT_LINE(' END OF PERFORMANCE REPORT');
    DBMS_OUTPUT.PUT_LINE('=====================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Please check your code and data.');
END;