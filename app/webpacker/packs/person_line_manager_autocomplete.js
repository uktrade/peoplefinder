import $ from 'jquery'
import 'select2'

window.addEventListener('DOMContentLoaded', () => {
    $('.js-line-manager-select').select2({
        ajax: {
            url: '/search/people.json',
            data: function (params) {
                return { query: params.term };
            },
            processResults: function (data) {
                return {
                    results: data
                };
            },
            dataType: 'json',
        },
        allowClear: true,
        placeholder: 'Select your manager',
        minimumInputLength: 4,
        templateResult: formatPerson,
        templateSelection: formatPersonSelection,
        selectOnClose: true
    });

    function formatPerson(person) {
        if(person.loading || person.name == null) {
            return person.text;
        }

        var $container = $(
            '<div class="select2-result-person">' +
            person.name +
            '<span class="select2-result-person__role">' +
            person.role_and_group +
            '</span>' +
            '</div>'
        );

        return $container;
    }

    function formatPersonSelection(person) {
        if(person.loading || person.name == null) {
            return person.text;
        }

        return person.name + ' (' + person.role_and_group + ')';
    }
})
